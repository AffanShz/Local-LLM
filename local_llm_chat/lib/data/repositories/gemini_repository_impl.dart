import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/errors/exceptions.dart';
import '../models/message.dart';
import 'ollama_repository.dart';

class GeminiRepositoryImpl implements OllamaRepository {
  bool _cancelled = false;

  @override
  Future<List<String>> getAvailableModels() async {
    return ['gemini-3.5-flash', 'gemini-2.5-flash'];
  }

  @override
  Stream<String> streamChat(List<Message> messages, String model) async* {
    _cancelled = false;

    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    final systemMessages = messages.where((m) => m.isSystem).toList();
    final chatMessages = messages.where((m) => !m.isSystem).toList();

    final systemInstruction = systemMessages.isNotEmpty
        ? Content.system(systemMessages.map((m) => m.content).join('\n'))
        : null;

    final genModel = GenerativeModel(
      model: model,
      apiKey: apiKey,
      systemInstruction: systemInstruction,
    );

    // Build history — all messages except the last user message
    final history = <Content>[];
    for (int i = 0; i < chatMessages.length - 1; i++) {
      final msg = chatMessages[i];
      if (msg.isUser) {
        history.add(Content.text(msg.content));
      } else if (msg.isAssistant) {
        history.add(Content.model([TextPart(msg.content)]));
      }
    }

    final lastMessage = chatMessages.last;
    final chat = genModel.startChat(history: history);

    try {
      final stream = chat.sendMessageStream(Content.text(lastMessage.content));

      await for (final chunk in stream) {
        if (_cancelled) throw const GenerationCancelledException();
        final text = chunk.text;
        if (text != null && text.isNotEmpty) yield text;
      }
    } catch (e) {
      if (e is GenerationCancelledException) {
        rethrow;
      } else if (_cancelled) {
        throw const GenerationCancelledException();
      } else {
        // Rethrow the actual error from Gemini API
        rethrow;
      }
    }
  }

  @override
  void cancelGeneration() {
    _cancelled = true;
  }
}
