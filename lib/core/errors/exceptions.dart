/// Base exception for all application errors
class AppException implements Exception {
  final String message;
  const AppException([this.message = 'Terjadi kesalahan pada aplikasi.']);

  @override
  String toString() => message;
}

/// Thrown when Ollama server is not running
class OllamaOfflineException extends AppException {
  const OllamaOfflineException([
    super.message =
        'Ollama tidak berjalan. Pastikan Ollama aktif di localhost:11434',
  ]);
}

/// Thrown when the requested model is not available
class ModelNotFoundException extends AppException {
  const ModelNotFoundException([super.message = 'Model LLM tidak ditemukan.']);
}

/// Thrown when generation is stopped by user
class GenerationCancelledException extends AppException {
  const GenerationCancelledException([
    super.message = 'Anda memberhentikan jawaban.',
  ]);
}

/// Thrown when database operations fail
class DatabaseException extends AppException {
  const DatabaseException([super.message = 'Terjadi kesalahan pada database.']);
}
