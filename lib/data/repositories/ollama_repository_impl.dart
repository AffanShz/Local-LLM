import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/errors/exceptions.dart';
import '../models/message.dart';
import 'ollama_repository.dart';

/// Concrete implementation of [OllamaRepository] using HTTP.
/// Encapsulates all Ollama API communication details.
class OllamaRepositoryImpl implements OllamaRepository {
  static const String _baseUrl = 'http://127.0.0.1:11434';
  http.Client _client = http.Client();

  @override
  Future<List<String>> getAvailableModels() async {
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/api/tags'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final models = data['models'] as List<dynamic>;
        return models
            .map((m) => (m as Map<String, dynamic>)['name'] as String)
            .toList();
      }
      throw const OllamaOfflineException();
    } catch (e) {
      if (e is OllamaOfflineException) rethrow;
      throw const OllamaOfflineException();
    }
  }

  @override
  Stream<String> streamChat(List<Message> messages, String model) async* {
    final request = http.Request('POST', Uri.parse('$_baseUrl/api/chat'));
    request.headers['Content-Type'] = 'application/json';
    request.body = jsonEncode({
      'model': model,
      'messages': messages.map((m) => m.toApiMap()).toList(),
      'stream': true,
    });

    try {
      final response = await _client.send(request);

      await for (final chunk in response.stream.transform(utf8.decoder)) {
        for (final line in chunk.split('\n')) {
          final trimmed = line.trim();
          if (trimmed.isEmpty) continue;
          try {
            final data = jsonDecode(trimmed) as Map<String, dynamic>;
            if (data.containsKey('message')) {
              final msg = data['message'] as Map<String, dynamic>;
              final token = (msg['content'] as String?) ?? '';
              if (token.isNotEmpty) yield token;
            }
          } catch (_) {
            // Skip malformed lines
          }
        }
      }
    } catch (e) {
      if (e is GenerationCancelledException) rethrow;
      throw const GenerationCancelledException();
    }
  }

  @override
  void cancelGeneration() {
    _client.close();
    _client = http.Client();
  }
}
