import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

class ChatInput extends StatefulWidget {
  final bool isStreaming;
  final void Function(String text) onSend;
  final VoidCallback onStop;

  const ChatInput({
    super.key,
    required this.isStreaming,
    required this.onSend,
    required this.onStop,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isStreaming) return;
    _controller.clear();
    widget.onSend(text);
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withOpacity(_isFocused ? 0.6 : 0.4)
                      : Colors.white.withOpacity(_isFocused ? 0.6 : 0.4),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _isFocused
                        ? const Color(0xFFFF8A3D)
                        : (isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.white.withOpacity(0.3)),
                    width: 1,
                  ),
                  boxShadow: [
                    if (_isFocused)
                      BoxShadow(
                        color: const Color(
                          0xFFFF8A3D,
                        ).withOpacity(isDark ? 0.2 : 0.1),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(width: 8),
                    Expanded(
                      child: KeyboardListener(
                        focusNode: FocusNode(),
                        onKeyEvent: (event) {
                          if (event is KeyDownEvent &&
                              event.logicalKey == LogicalKeyboardKey.enter &&
                              !HardwareKeyboard.instance.isShiftPressed) {
                            _handleSend();
                          }
                        },
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          maxLines: 5,
                          minLines: 1,
                          textInputAction: TextInputAction.newline,
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFFFFEDE5)
                                : const Color(0xFF241914),
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(
                              color: isDark
                                  ? const Color(0xFF8A7266)
                                  : const Color(0xFF8A7266),
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: widget.isStreaming
                            ? (isDark ? const Color(0xFFFFB4AB) : Colors.red)
                            : _isFocused || _controller.text.isNotEmpty
                            ? const Color(0xFFFF8A3D)
                            : (isDark
                                  ? Colors.black.withOpacity(0.4)
                                  : Colors.white.withOpacity(0.5)),
                        shape: BoxShape.circle,
                        boxShadow: [
                          if (_isFocused || _controller.text.isNotEmpty)
                            BoxShadow(
                              color: const Color(
                                0xFFFF8A3D,
                              ).withOpacity(isDark ? 0.4 : 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          widget.isStreaming ? Icons.stop : Icons.arrow_upward,
                          color:
                              (_isFocused ||
                                  _controller.text.isNotEmpty ||
                                  widget.isStreaming)
                              ? (isDark && widget.isStreaming
                                    ? Colors.red[900]
                                    : Colors.white)
                              : (isDark
                                    ? const Color(0xFFDDC1B3)
                                    : const Color(0xFF8A7266)),
                        ),
                        onPressed: widget.isStreaming
                            ? widget.onStop
                            : _handleSend,
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
