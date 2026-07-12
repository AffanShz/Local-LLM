import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../core/errors/exceptions.dart';
import '../models/message.dart';
import 'ollama_repository.dart';

/// Concrete implementation of [OllamaRepository] for the Anthropic Claude API.
/// Talks to the Messages API (`POST /v1/messages`) via SSE streaming.
/// Base URL and API key are read from .env (ANTHROPIC_BASE_URL / ANTHROPIC_API_KEY).
class ClaudeRepositoryImpl implements OllamaRepository {
  http.Client _client = http.Client();
  bool _cancelled = false;

  String get _baseUrl {
    final url = dotenv.env['ANTHROPIC_BASE_URL'] ?? 'https://api.anthropic.com';
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  String get _apiKey => dotenv.env['ANTHROPIC_API_KEY'] ?? '';

  @override
  Future<List<String>> getAvailableModels() async {
    // Models served by the proxy at ANTHROPIC_BASE_URL — adjust when the
    // provider adds/removes models.
    return ['claude-sonnet-4-6'];
  }

  int _maxTokensFor(String model) {
    if (model.contains('haiku')) return 8192;
    if (model.contains('sonnet')) return 16000;
    return 32000; // opus / default
  }

  @override
  Stream<String> streamChat(List<Message> messages, String model) async* {
    // The Messages API takes the system prompt as a separate top-level field,
    // not as a message with role "system".
    final systemPrompt = messages
        .where((m) => m.isSystem)
        .map((m) => m.content)
        .join('\n');
    final chatMessages = messages
        .where((m) => !m.isSystem)
        .map((m) => m.toApiMap())
        .toList();

    final request = http.Request('POST', Uri.parse('$_baseUrl/v1/messages'));
    request.headers['Content-Type'] = 'application/json';
    request.headers['x-api-key'] = _apiKey;
    request.headers['anthropic-version'] = '2023-06-01';
    request.body = jsonEncode({
      'model': model,
      'max_tokens': _maxTokensFor(model),
      if (systemPrompt.isNotEmpty) 'system': systemPrompt,
      'messages': chatMessages,
      'stream': true,
    });

    _cancelled = false;
    try {
      final response = await _client.send(request);

      if (response.statusCode != 200) {
        final body = await response.stream.bytesToString();
        String message = 'Claude API error (${response.statusCode})';
        try {
          final data = jsonDecode(body) as Map<String, dynamic>;
          final err = data['error'] as Map<String, dynamic>?;
          if (err?['message'] != null) {
            message = 'Claude API: ${err!['message']}';
          }
        } catch (_) {}
        throw AppException(message);
      }

      // SSE lines can be split across chunks — buffer until newline.
      String buffer = '';
      await for (final chunk in response.stream.transform(utf8.decoder)) {
        buffer += chunk;
        final lines = buffer.split('\n');
        buffer = lines.removeLast();

        for (final line in lines) {
          final trimmed = line.trim();
          if (!trimmed.startsWith('data:')) continue;
          final payload = trimmed.substring(5).trim();
          if (payload.isEmpty) continue;

          Map<String, dynamic> data;
          try {
            data = jsonDecode(payload) as Map<String, dynamic>;
          } catch (_) {
            continue;
          }

          switch (data['type']) {
            case 'content_block_delta':
              final delta = data['delta'] as Map<String, dynamic>?;
              if (delta?['type'] == 'text_delta') {
                final token = (delta?['text'] as String?) ?? '';
                if (token.isNotEmpty) yield token;
              }
              break;
            case 'message_delta':
              final stopReason =
                  (data['delta'] as Map<String, dynamic>?)?['stop_reason'];
              if (stopReason == 'refusal') {
                throw const AppException(
                  'Claude menolak permintaan ini karena kebijakan keamanan. '
                  'Coba model lain atau ubah pertanyaannya.',
                );
              }
              break;
            case 'error':
              final err = data['error'] as Map<String, dynamic>?;
              throw AppException(
                'Claude API: ${err?['message'] ?? 'unknown error'}',
              );
          }
        }
      }
    } on AppException {
      rethrow;
    } catch (e) {
      if (_cancelled) throw const GenerationCancelledException();
      throw AppException('Gagal menghubungi Claude: $e');
    }
  }

  @override
  void cancelGeneration() {
    _cancelled = true;
    _client.close();
    _client = http.Client();
  }
}
