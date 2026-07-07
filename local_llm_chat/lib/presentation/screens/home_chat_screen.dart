import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../providers/providers.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/model_selector.dart';
import '../widgets/sidebar_conversations.dart';
import '../widgets/orb_widget.dart';

class HomeChatScreen extends ConsumerStatefulWidget {
  const HomeChatScreen({super.key});

  @override
  ConsumerState<HomeChatScreen> createState() => _HomeChatScreenState();
}

class _HomeChatScreenState extends ConsumerState<HomeChatScreen> {
  bool _sidebarVisible = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _onConversationSelected(String conversationId) async {
    await ref.read(chatProvider.notifier).loadMessages(conversationId);
    _scrollToBottom();
  }

  Future<void> _onSendMessage(String text) async {
    final activeId = ref.read(activeConversationIdProvider);
    if (activeId == null) return;

    final model = ref.read(selectedModelProvider);

    if (model.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih model terlebih dahulu.'),
          backgroundColor: Color(0xFFFF8A3D),
        ),
      );
      return;
    }

    await ref
        .read(chatProvider.notifier)
        .sendMessage(
          text: text,
          model: model,
          conversationId: activeId,
        );
    _scrollToBottom();
  }

  void _showNewChatDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final promptController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2A1C15).withOpacity(0.9) : Colors.white.withOpacity(0.9),
        surfaceTintColor: Colors.transparent,
        title: Text(
          'New Chat',
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: isDark ? const Color(0xFFFFEDE5) : const Color(0xFF241914)
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: promptController,
              maxLines: 3,
              style: TextStyle(color: isDark ? const Color(0xFFFFEDE5) : const Color(0xFF241914)),
              decoration: InputDecoration(
                labelText: 'System Prompt (Optional)',
                labelStyle: TextStyle(color: isDark ? const Color(0xFFDDC1B3) : const Color(0xFF8A7266)),
                hintText: 'e.g., Answer in Indonesian',
                hintStyle: TextStyle(color: isDark ? const Color(0xFF8A7266) : const Color(0xFFDDC1B3)),
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFF8A3D), width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: isDark ? const Color(0xFFDDC1B3) : const Color(0xFF8A7266))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8A3D), // primary
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final systemPrompt = promptController.text.trim().isEmpty
                  ? 'Kamu adalah asisten AI yang membantu dalam Bahasa Indonesia.'
                  : promptController.text.trim();

              final id = await ref
                  .read(conversationsProvider.notifier)
                  .createConversation(systemPrompt: systemPrompt);

              ref.read(activeConversationIdProvider.notifier).state = id;
              ref.read(chatProvider.notifier).clearMessages();
              _onConversationSelected(id);
            },
            child: const Text('Create Chat'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatAsync = ref.watch(chatProvider);
    final activeId = ref.watch(activeConversationIdProvider);
    ref.watch(selectedModelSyncProvider);

    ref.listen(chatProvider, (_, next) => _scrollToBottom());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          // ── Sidebar ──────────────────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: _sidebarVisible ? 280 : 0,
            child: ClipRect(
              child: _sidebarVisible
                  ? Container(
                      color: isDark ? const Color(0xFF2A1C15) : const Color(0xFFF3DED5), // surface-variant
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Brand Header
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 24, 16, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF1E130D) : const Color(0xFFFFF8F6),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.5),
                                          width: 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFFF8A3D).withOpacity(isDark ? 0.2 : 0.1),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          )
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.auto_awesome,
                                        color: Color(0xFFFF8A3D),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Orange AI',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? const Color(0xFFFFEDE5) : const Color(0xFF241914), // on-background
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        Text(
                                          'LocalLLM Client',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: isDark ? const Color(0xFFDDC1B3) : const Color(0xFF564338), // on-surface-variant
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: Icon(Icons.menu_open, size: 20, color: isDark ? const Color(0xFFDDC1B3) : const Color(0xFF564338)),
                                      onPressed: () => setState(() => _sidebarVisible = false),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),
                                // New Chat Button
                                Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFF8A3D).withOpacity(isDark ? 0.3 : 0.2),
                                        blurRadius: 30,
                                        spreadRadius: -5,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: _showNewChatDialog,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF8A3D), // primary
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(double.infinity, 52),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    icon: const Icon(Icons.add, size: 20),
                                    label: const Text(
                                      'New Chat',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Conversation list
                          Expanded(
                            child: SidebarConversations(
                              onConversationSelected: _onConversationSelected,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),

          // ── Chat area ─────────────────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                Column(
                  children: [
                    // Header bar
                    Container(
                      height: 72,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.6),
                        border: Border(
                          bottom: BorderSide(
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: ClipRRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Row(
                            children: [
                              if (!_sidebarVisible)
                                IconButton(
                                  icon: Icon(Icons.menu, color: isDark ? const Color(0xFFFFEDE5) : const Color(0xFF241914)),
                                  tooltip: 'Buka sidebar',
                                  onPressed: () =>
                                      setState(() => _sidebarVisible = true),
                                ),
                              const SizedBox(width: 8),
                              const ModelSelector(),
                              const Spacer(),
                              IconButton(
                                icon: Icon(
                                  isDark ? Icons.light_mode : Icons.dark_mode,
                                  color: isDark ? const Color(0xFFDDC1B3) : const Color(0xFF8A7266),
                                ),
                                tooltip: 'Toggle Theme',
                                onPressed: () {
                                  final current = ref.read(themeProvider);
                                  if (current == ThemeMode.dark || (current == ThemeMode.system && isDark)) {
                                    ref.read(themeProvider.notifier).state = ThemeMode.light;
                                  } else {
                                    ref.read(themeProvider.notifier).state = ThemeMode.dark;
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Message list
                    Expanded(
                      child: activeId == null
                          ? _buildEmptyState(isDark)
                          : chatAsync.when(
                              loading: () => const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFFF8A3D),
                                ),
                              ),
                              error: (e, _) => Center(
                                child: Text(
                                  'Error: $e',
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                              data: (chatState) => _buildMessageList(chatState, isDark),
                            ),
                    ),

                    // Input bar (only when a conversation is active)
                    if (activeId != null)
                      chatAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, e) => const SizedBox.shrink(),
                        data: (chatState) => ChatInput(
                          isStreaming: chatState.isStreaming,
                          onSend: _onSendMessage,
                          onStop: () =>
                              ref.read(chatProvider.notifier).stopGeneration(),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const OrbWidget(size: 140, withText: true),
          const SizedBox(height: 48),
          Text(
            'Good Morning! How can I help?',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFFFEDE5) : const Color(0xFF241914), // on-background
              letterSpacing: -0.01,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 480,
            child: Text(
              'Select a model from the top bar or just start typing. Your data stays completely private and processed on-device.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? const Color(0xFFDDC1B3) : const Color(0xFF564338), // on-surface-variant
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 48),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF8A3D).withOpacity(isDark ? 0.25 : 0.15),
                  blurRadius: 40,
                  spreadRadius: 5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _showNewChatDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8A3D), // primary
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              icon: const Icon(Icons.add, size: 24),
              label: const Text(
                'New Chat',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(ChatState chatState, bool isDark) {
    final messages = chatState.messages;
    final isStreaming = chatState.isStreaming;
    final streamingText = chatState.streamingText;
    final errorMessage = chatState.errorMessage;

    if (messages.isEmpty && !isStreaming && errorMessage == null) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 24, bottom: 24),
      itemCount:
          messages.length +
          (isStreaming ? 1 : 0) +
          (errorMessage != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (errorMessage != null &&
            index == messages.length + (isStreaming ? 1 : 0)) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.red.withOpacity(0.2) : Colors.red[50],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: isDark ? Colors.red[300] : Colors.red, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: TextStyle(color: isDark ? Colors.red[300] : Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        if (isStreaming && index == messages.length) {
          return Column(
            children: [
              ChatBubble(text: streamingText, isUser: false),
              const Padding(
                padding: EdgeInsets.only(left: 40, bottom: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 40,
                    child: LinearProgressIndicator(
                      color: Color(0xFFFF8A3D),
                      backgroundColor: Color(0xFFFFDCC7),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        final msg = messages[index];
        return ChatBubble(text: msg.content, isUser: msg.isUser);
      },
    );
  }
}
