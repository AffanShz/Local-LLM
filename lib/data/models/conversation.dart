/// Represents a chat conversation session.
/// Encapsulates the conversation metadata and system prompt.
class Conversation {
  final String id;
  final String title;
  final String systemPrompt;
  final String model;
  final int createdAt;
  final int updatedAt;

  const Conversation({
    required this.id,
    required this.title,
    required this.systemPrompt,
    this.model = '',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert to Map for SQLite storage
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'system_prompt': systemPrompt,
      'model': model,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Create from SQLite Map
  factory Conversation.fromMap(Map<String, Object?> map) {
    return Conversation(
      id: map['id'] as String,
      title: map['title'] as String,
      systemPrompt: (map['system_prompt'] as String?) ?? '',
      model: (map['model'] as String?) ?? '',
      createdAt: (map['created_at'] as num).toInt(),
      updatedAt: (map['updated_at'] as num).toInt(),
    );
  }

  /// Create a copy with updated fields
  Conversation copyWith({
    String? id,
    String? title,
    String? systemPrompt,
    String? model,
    int? createdAt,
    int? updatedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      model: model ?? this.model,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
