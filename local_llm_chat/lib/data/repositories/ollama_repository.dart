import '../models/message.dart';

/// Abstract contract for LLM communication.
/// Enables polymorphism — swap Ollama for any other LLM backend
/// without touching the rest of the app (Abstraction principle).
abstract class OllamaRepository {
  /// Fetch list of available model names from Ollama.
  Future<List<String>> getAvailableModels();

  /// Stream chat tokens from Ollama given a list of messages and model name.
  Stream<String> streamChat(List<Message> messages, String model);

  /// Cancel the current in-flight generation request.
  void cancelGeneration();
}
