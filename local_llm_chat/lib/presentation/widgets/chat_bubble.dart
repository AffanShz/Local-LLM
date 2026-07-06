import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:highlight/highlight.dart' as highlight;
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';

/// Custom syntax highlighter for code blocks
class CodeHighlighter extends SyntaxHighlighter {
  final bool isDark;

  CodeHighlighter(this.isDark);

  @override
  TextSpan format(String source) {
    try {
      final result = highlight.highlight.parse(source, autoDetection: true);
      return _buildTextSpan(result.nodes, isDark);
    } catch (e) {
      // Fallback to plain text if highlighting fails
      return TextSpan(
        text: source,
        style: TextStyle(
          fontFamily: 'monospace',
          color: isDark ? const Color(0xFFFFEDE5) : const Color(0xFF241914),
        ),
      );
    }
  }

  TextSpan _buildTextSpan(List<highlight.Node>? nodes, bool isDark) {
    if (nodes == null || nodes.isEmpty) {
      return const TextSpan();
    }

    final List<TextSpan> spans = [];
    for (final node in nodes) {
      if (node.children != null && node.children!.isNotEmpty) {
        spans.add(_buildTextSpan(node.children, isDark));
      } else {
        spans.add(TextSpan(
          text: node.value,
          style: _getStyleForClassName(node.className, isDark),
        ));
      }
    }
    return TextSpan(children: spans);
  }

  TextStyle _getStyleForClassName(String? className, bool isDark) {
    final baseStyle = TextStyle(
      fontFamily: 'monospace',
      color: isDark ? const Color(0xFFFFEDE5) : const Color(0xFF241914),
    );

    if (className == null) return baseStyle;

    // Syntax colors for dark/light themes
    final Map<String, Color> darkColors = {
      'keyword': const Color(0xFFFF8A3D),      // Orange
      'built_in': const Color(0xFFFFB86B),     // Light orange
      'string': const Color(0xFF98C379),       // Green
      'number': const Color(0xFFD19A66),       // Amber
      'comment': const Color(0xFF8A7266),      // Muted brown
      'function': const Color(0xFF61AFEF),     // Blue
      'class': const Color(0xFFE5C07B),        // Yellow
      'type': const Color(0xFFE5C07B),         // Yellow
      'variable': const Color(0xFFE06C75),     // Red
      'operator': const Color(0xFF56B6C2),     // Cyan
    };

    final Map<String, Color> lightColors = {
      'keyword': const Color(0xFFFF8A3D),      // Orange
      'built_in': const Color(0xFFD35400),     // Dark orange
      'string': const Color(0xFF27AE60),       // Green
      'number': const Color(0xFFE67E22),       // Orange
      'comment': const Color(0xFF95A5A6),      // Gray
      'function': const Color(0xFF3498DB),     // Blue
      'class': const Color(0xFFF39C12),        // Yellow
      'type': const Color(0xFFF39C12),         // Yellow
      'variable': const Color(0xFFE74C3C),     // Red
      'operator': const Color(0xFF16A085),     // Teal
    };

    final colors = isDark ? darkColors : lightColors;
    final color = colors[className] ?? baseStyle.color;

    return baseStyle.copyWith(color: color);
  }
}

/// Renders a single chat message bubble.
/// User messages align right, AI messages align left.
/// Uses the "Liquid Glass" design system and supports Dark Mode.
class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatBubble({super.key, required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24),
            topRight: const Radius.circular(24),
            bottomLeft: Radius.circular(isUser ? 24 : 8),
            bottomRight: Radius.circular(isUser ? 8 : 24),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isUser 
                    ? (isDark ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.6))
                    : null,
                gradient: isUser
                    ? null
                    : LinearGradient(
                        colors: [
                          isDark ? Colors.black.withOpacity(0.6) : Colors.white.withOpacity(0.9),
                          isDark ? const Color(0xFFFF8A3D).withOpacity(0.15) : const Color(0xFFFF8A3D).withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(24),
                  topRight: const Radius.circular(24),
                  bottomLeft: Radius.circular(isUser ? 24 : 8),
                  bottomRight: Radius.circular(isUser ? 8 : 24),
                ),
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF8A3D).withOpacity(isDark ? 0.15 : 0.1),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: MarkdownBody(
                data: text,
                selectable: true,
                syntaxHighlighter: CodeHighlighter(isDark),
                onTapLink: (text, href, title) async {
                  if (href != null) {
                    final uri = Uri.tryParse(href);
                    if (uri != null && await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  }
                },
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    color: isDark ? const Color(0xFFFFEDE5) : const Color(0xFF241914),
                    fontSize: 16,
                    height: 1.5,
                  ),
                  a: const TextStyle(
                    color: Color(0xFFFF8A3D),
                    decoration: TextDecoration.underline,
                  ),
                  code: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    color: isDark ? const Color(0xFFFF8A3D) : const Color(0xFFD35400),
                    backgroundColor: isDark ? const Color(0x33000000) : const Color(0x1AFF8A3D),
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: isDark ? const Color(0x80000000) : const Color(0x80FFFFFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0x1AFFFFFF) : const Color(0x66FFFFFF),
                    ),
                  ),
                  codeblockPadding: const EdgeInsets.all(16),
                  blockSpacing: 8,
                  listBullet: TextStyle(
                    color: isDark ? const Color(0xFFFF8A3D) : const Color(0xFFD35400),
                  ),
                  strong: TextStyle(
                    color: isDark ? const Color(0xFFFFEDE5) : const Color(0xFF241914),
                    fontWeight: FontWeight.bold,
                  ),
                  em: TextStyle(
                    color: isDark ? const Color(0xFFDDC1B3) : const Color(0xFF564338),
                    fontStyle: FontStyle.italic,
                  ),
                  h1: TextStyle(
                    color: isDark ? const Color(0xFFFFEDE5) : const Color(0xFF241914),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  h2: TextStyle(
                    color: isDark ? const Color(0xFFFFEDE5) : const Color(0xFF241914),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  h3: TextStyle(
                    color: isDark ? const Color(0xFFFFEDE5) : const Color(0xFF241914),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
