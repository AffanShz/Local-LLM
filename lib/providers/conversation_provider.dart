import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/local_db/database_helper.dart';
import '../data/models/conversation.dart';

final _dbProvider = Provider<DatabaseHelper>((ref) => DatabaseHelper());

/// Manages the list of conversations (sessions).
/// Handles create, load, rename, and delete operations.
final conversationsProvider =
    AsyncNotifierProvider<ConversationsNotifier, List<Conversation>>(
      ConversationsNotifier.new,
    );

class ConversationsNotifier extends AsyncNotifier<List<Conversation>> {
  late DatabaseHelper _db;
  final _uuid = const Uuid();

  @override
  Future<List<Conversation>> build() async {
    _db = ref.watch(_dbProvider);
    return _db.getAllConversations();
  }

  /// Create a new conversation and return its ID.
  Future<String> createConversation({
    String title = 'Obrolan Baru',
    String systemPrompt = '',
    String model = '',
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final conversation = Conversation(
      id: _uuid.v4(),
      title: title,
      systemPrompt: systemPrompt,
      model: model,
      createdAt: now,
      updatedAt: now,
    );
    await _db.insertConversation(conversation);
    await _reload();
    return conversation.id;
  }

  /// Rename an existing conversation.
  Future<void> renameConversation(String id, String newTitle) async {
    await _db.updateConversationTitle(id, newTitle);
    await _reload();
  }

  /// Update system prompt for an existing conversation.
  Future<void> updateSystemPrompt(String id, String systemPrompt) async {
    await _db.updateSystemPrompt(id, systemPrompt);
    await _reload();
  }

  /// Delete a conversation (messages cascade via FK).
  Future<void> deleteConversation(String id) async {
    await _db.deleteConversation(id);
    await _reload();
  }

  Future<void> _reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _db.getAllConversations());
  }
}

/// Tracks which conversation is currently selected (null = none).
final activeConversationIdProvider = StateProvider<String?>((ref) => null);
