/// Represents information about an available Ollama model.
class ModelInfo {
  final String name;
  final int? size;

  const ModelInfo({required this.name, this.size});

  factory ModelInfo.fromMap(Map<String, Object?> map) {
    return ModelInfo(
      name: map['name'] as String,
      size: (map['size'] as num?)?.toInt(),
    );
  }
}
