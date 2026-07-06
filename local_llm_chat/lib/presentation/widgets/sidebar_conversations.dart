import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local_db/database_helper.dart';
import '../../providers/providers.dart';

class SidebarConversations extends ConsumerWidget {
  final void Function(String conversationId) onConversationSelected;

  const SidebarConversations({super.key, required this.onConversationSelected});

  void _showRenameDialog(BuildContext context, WidgetRef ref, String id, String currentTitle) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = TextEditingController(text: currentTitle);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2A1C15) : Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text('Rename Chat',
            style: TextStyle(color: isDark ? const Color(0xFFFFEDE5) : const Color(0xFF241914))),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: isDark ? const Color(0xFFFFEDE5) : const Color(0xFF241914)),
          decoration: InputDecoration(
            labelText: 'Title',
            labelStyle: TextStyle(color: isDark ? const Color(0xFFDDC1B3) : const Color(0xFF8A7266)),
            border: const OutlineInputBorder(),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFFF8A3D), width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: isDark ? const Color(0xFFDDC1B3) : const Color(0xFF8A7266))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8A3D),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty) {
                await ref.read(conversationsProvider.notifier).renameConversation(id, newTitle);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditSystemPromptDialog(BuildContext context, WidgetRef ref, String id) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final conversation = await DatabaseHelper().getConversationById(id);
    if (!context.mounted) return;
    final controller = TextEditingController(text: conversation?.systemPrompt ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2A1C15) : Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text('Edit System Prompt',
            style: TextStyle(color: isDark ? const Color(0xFFFFEDE5) : const Color(0xFF241914))),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 5,
          style: TextStyle(color: isDark ? const Color(0xFFFFEDE5) : const Color(0xFF241914)),
          decoration: InputDecoration(
            labelText: 'System Prompt',
            labelStyle: TextStyle(color: isDark ? const Color(0xFFDDC1B3) : const Color(0xFF8A7266)),
            hintText: 'e.g., Jawab selalu dengan awalan 6767',
            hintStyle: TextStyle(color: isDark ? const Color(0xFF8A7266) : const Color(0xFFDDC1B3)),
            border: const OutlineInputBorder(),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFFF8A3D), width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: isDark ? const Color(0xFFDDC1B3) : const Color(0xFF8A7266))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8A3D),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await ref.read(conversationsProvider.notifier).updateSystemPrompt(id, controller.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final conversationsAsync = ref.watch(conversationsProvider);
    final activeId = ref.watch(activeConversationIdProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: conversationsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFFF8A3D))),
            error: (e, _) => Center(
              child: Text('Error: $e', style: const TextStyle(color: Colors.red)),
            ),
            data: (conversations) {
              if (conversations.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No recent chats.\nPress "New Chat" to start.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: isDark ? const Color(0xFFDDC1B3) : const Color(0xFF8A7266)),
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conv = conversations[index];
                  final isSelected = conv.id == activeId;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        ref.read(activeConversationIdProvider.notifier).state = conv.id;
                        onConversationSelected(conv.id);
                      },
                      onLongPress: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: isDark ? const Color(0xFF2A1C15) : Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (_) => SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 40,
                                  height: 4,
                                  margin: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white24 : Colors.black12,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.edit_outlined, color: Color(0xFFFF8A3D)),
                                  title: Text('Rename',
                                      style: TextStyle(color: isDark ? const Color(0xFFFFEDE5) : const Color(0xFF241914))),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _showRenameDialog(context, ref, conv.id, conv.title);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.tune_outlined, color: Color(0xFFFF8A3D)),
                                  title: Text('Edit System Prompt',
                                      style: TextStyle(color: isDark ? const Color(0xFFFFEDE5) : const Color(0xFF241914))),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _showEditSystemPromptDialog(context, ref, conv.id);
                                  },
                                ),
                                ListTile(
                                  leading: Icon(Icons.delete_outline,
                                      color: isDark ? const Color(0xFFFFB4AB) : const Color(0xFFBA1A1A)),
                                  title: Text('Delete',
                                      style: TextStyle(color: isDark ? const Color(0xFFFFB4AB) : const Color(0xFFBA1A1A))),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    await ref.read(conversationsProvider.notifier).deleteConversation(conv.id);
                                    if (isSelected) {
                                      ref.read(activeConversationIdProvider.notifier).state = null;
                                      ref.read(chatProvider.notifier).clearMessages();
                                    }
                                  },
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFF8A3D).withAlpha(isDark ? 64 : 38)
                              : (isDark ? Colors.black.withAlpha(51) : Colors.white.withAlpha(102)),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFFF8A3D).withAlpha(isDark ? 153 : 128)
                                : (isDark ? Colors.white.withAlpha(13) : Colors.white.withAlpha(77)),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.chat_bubble : Icons.chat_bubble_outline,
                              size: 18,
                              color: isSelected
                                  ? const Color(0xFFFF8A3D)
                                  : (isDark ? const Color(0xFFDDC1B3) : const Color(0xFF8A7266)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                conv.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: isSelected
                                      ? (isDark ? const Color(0xFFFFEDE5) : const Color(0xFF682D00))
                                      : (isDark ? const Color(0xFFDDC1B3) : const Color(0xFF241914)),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                await ref.read(conversationsProvider.notifier).deleteConversation(conv.id);
                                if (isSelected) {
                                  ref.read(activeConversationIdProvider.notifier).state = null;
                                  ref.read(chatProvider.notifier).clearMessages();
                                }
                              },
                              child: Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: isDark ? const Color(0xFFFFB4AB) : const Color(0xFFBA1A1A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
