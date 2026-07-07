/// Represents a single message in a conversation.
/// Encapsulates the role, content, and metadata of each message.
class Message {
  final String id;
  final String conversationId;
  final String role; // 'system', 'user', 'assistant'
  final String content;
  final String status; // 'sending', 'streaming', 'done', 'failed'

  const Message({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    this.status = 'done',
  });

  /// Whether this message is from the user
  bool get isUser => role == 'user';

  /// Whether this message is from the assistant
  bool get isAssistant => role == 'assistant';

  /// Whether this message is a system prompt
  bool get isSystem => role == 'system';

  /// Convert to Map for SQLite storage
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'role': role,
      'content': content,
      'status': status,
    };
  }

  /// Convert to Map for Ollama API request
  Map<String, String> toApiMap() {
    return {'role': role, 'content': content};
  }

  /// Create from SQLite Map
  factory Message.fromMap(Map<String, Object?> map) {
    return Message(
      id: map['id'] as String,
      conversationId: map['conversation_id'] as String,
      role: map['role'] as String,
      content: map['content'] as String,
      status: (map['status'] as String?) ?? 'done',
    );
  }

  /// Create a copy with updated fields
  Message copyWith({
    String? id,
    String? conversationId,
    String? role,
    String? content,
    String? status,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      status: status ?? this.status,
    );
  }
}
