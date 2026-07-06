import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../core/errors/exceptions.dart';
import '../data/local_db/database_helper.dart';
import '../data/models/message.dart';
import '../data/repositories/ollama_repository.dart';
import 'models_provider.dart';
import 'conversation_provider.dart';

final _chatDbProvider = Provider<DatabaseHelper>((ref) => DatabaseHelper());

/// Immutable state for the chat area.
class ChatState {
  final List<Message> messages;
  final bool isStreaming;
  final String streamingText;
  final String? errorMessage;

  const ChatState({
    this.messages = const [],
    this.isStreaming = false,
    this.streamingText = '',
    this.errorMessage,
  });

  ChatState copyWith({
    List<Message>? messages,
    bool? isStreaming,
    String? streamingText,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isStreaming: isStreaming ?? this.isStreaming,
      streamingText: streamingText ?? this.streamingText,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Manages messages and streaming state for the active conversation.
final chatProvider = AsyncNotifierProvider<ChatNotifier, ChatState>(
  ChatNotifier.new,
);

class ChatNotifier extends AsyncNotifier<ChatState> {
  late DatabaseHelper _db;
  late OllamaRepository _repository;
  final _uuid = const Uuid();

  @override
  Future<ChatState> build() async {
    _db = ref.watch(_chatDbProvider);
    _repository = ref.watch(activeRepositoryProvider);
    return const ChatState();
  }

  /// Load messages for a conversation from the database.
  Future<void> loadMessages(String conversationId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final messages = await _db.getMessagesByConversation(conversationId);
      return ChatState(messages: messages);
    });
  }

  /// Send a user message and stream the assistant response.
  Future<void> sendMessage({
    required String text,
    required String model,
    required String conversationId,
  }) async {
    final current = state.valueOrNull ?? const ChatState();
    if (current.isStreaming) return;

    // Always fetch system prompt fresh from DB to pick up any edits
    final conversation = await _db.getConversationById(conversationId);
    final systemPrompt = conversation?.systemPrompt ?? '';

    // Auto-generate title from first message
    if (current.messages.isEmpty) {
      final title = text.length > 30 ? '${text.substring(0, 30)}...' : text;
      await _db.updateConversationTitle(conversationId, title);
      ref.invalidate(conversationsProvider);
    }

    // Persist user message
    final userMsg = Message(
      id: _uuid.v4(),
      conversationId: conversationId,
      role: 'user',
      content: text,
      status: 'done',
    );
    await _db.insertMessage(userMsg);

    final updatedMessages = [...current.messages, userMsg];
    state = AsyncData(
      current.copyWith(
        messages: updatedMessages,
        isStreaming: true,
        streamingText: '',
        clearError: true,
      ),
    );

    // Build messages list for Ollama API — system prompt always first
    final apiMessages = <Message>[];
    if (systemPrompt.isNotEmpty) {
      apiMessages.add(
        Message(
          id: 'system',
          conversationId: conversationId,
          role: 'system',
          content: systemPrompt,
        ),
      );
    }
    apiMessages.addAll(updatedMessages);

    String fullResponse = '';

    try {
      await for (final token in _repository.streamChat(apiMessages, model)) {
        fullResponse += token;
        state = AsyncData(
          (state.valueOrNull ?? const ChatState()).copyWith(
            streamingText: fullResponse,
            isStreaming: true,
          ),
        );
      }

      // Persist completed assistant message
      final assistantMsg = Message(
        id: _uuid.v4(),
        conversationId: conversationId,
        role: 'assistant',
        content: fullResponse,
        status: 'done',
      );
      await _db.insertMessage(assistantMsg);

      state = AsyncData(
        (state.valueOrNull ?? const ChatState()).copyWith(
          messages: [...updatedMessages, assistantMsg],
          isStreaming: false,
          streamingText: '',
          clearError: true,
        ),
      );

      ref.invalidate(conversationsProvider);
    } on GenerationCancelledException {
      // User stopped — save partial response if non-empty
      if (fullResponse.isNotEmpty) {
        final partialMsg = Message(
          id: _uuid.v4(),
          conversationId: conversationId,
          role: 'assistant',
          content: fullResponse,
          status: 'done',
        );
        await _db.insertMessage(partialMsg);
        state = AsyncData(
          (state.valueOrNull ?? const ChatState()).copyWith(
            messages: [...updatedMessages, partialMsg],
            isStreaming: false,
            streamingText: '',
            clearError: true,
          ),
        );
      } else {
        state = AsyncData(
          (state.valueOrNull ?? const ChatState()).copyWith(
            isStreaming: false,
            streamingText: '',
            clearError: true,
          ),
        );
      }
    } catch (e) {
      state = AsyncData(
        (state.valueOrNull ?? const ChatState()).copyWith(
          isStreaming: false,
          streamingText: '',
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Stop the current generation.
  void stopGeneration() {
    _repository.cancelGeneration();
  }

  /// Clear messages when switching conversations.
  void clearMessages() {
    state = const AsyncData(ChatState());
  }
}
