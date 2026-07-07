import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';

class ModelSelector extends ConsumerWidget {
  const ModelSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modelsAsync = ref.watch(modelsProvider);
    final selectedModel = ref.watch(selectedModelProvider);
    final isOnline = ref.watch(isOnlineProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Online/offline indicator
        _ConnectivityBadge(isOnline: isOnline),
        const SizedBox(width: 12),
        // Model dropdown
        modelsAsync.when(
          loading: () => const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF8A3D)),
          ),
          error: (e, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 18),
              const SizedBox(width: 6),
              const Text('Ollama offline', style: TextStyle(color: Colors.red, fontSize: 13)),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => ref.read(modelsProvider.notifier).refresh(),
                child: const Text('Coba lagi', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          data: (models) {
            if (models.isEmpty) {
              return Text(
                isOnline ? 'Tidak ada model' : 'Ollama offline & tidak ada internet',
                style: TextStyle(
                  color: isDark ? const Color(0xFFDDC1B3) : const Color(0xFF8A7266),
                  fontSize: 13,
                ),
              );
            }

            final value = models.contains(selectedModel) ? selectedModel : models.first;

            return DropdownButton<String>(
              value: value,
              underline: const SizedBox(),
              isDense: true,
              items: models.map((m) {
                final isGemini = m.startsWith('gemini-');
                return DropdownMenuItem<String>(
                  value: m,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isGemini) ...[
                        const Icon(Icons.cloud_outlined, size: 14, color: Color(0xFF4285F4)),
                        const SizedBox(width: 4),
                      ] else ...[
                        const Icon(Icons.computer_outlined, size: 14, color: Color(0xFFFF8A3D)),
                        const SizedBox(width: 4),
                      ],
                      Text(m, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (newModel) {
                if (newModel != null) {
                  ref.read(selectedModelProvider.notifier).state = newModel;
                }
              },
            );
          },
        ),
      ],
    );
  }
}

class _ConnectivityBadge extends StatelessWidget {
  final bool isOnline;

  const _ConnectivityBadge({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Tooltip(
      message: isOnline ? 'Online — Gemini tersedia' : 'Offline — hanya model lokal',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isOnline
              ? const Color(0xFF34A853).withAlpha(isDark ? 38 : 25)
              : (isDark ? Colors.white.withAlpha(13) : Colors.black.withAlpha(13)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isOnline
                ? const Color(0xFF34A853).withAlpha(isDark ? 100 : 77)
                : (isDark ? Colors.white.withAlpha(38) : Colors.black.withAlpha(38)),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnline ? const Color(0xFF34A853) : const Color(0xFF8A7266),
                boxShadow: isOnline
                    ? [
                        BoxShadow(
                          color: const Color(0xFF34A853).withAlpha(150),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isOnline ? 'Online' : 'Offline',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isOnline
                    ? const Color(0xFF34A853)
                    : (isDark ? const Color(0xFF8A7266) : const Color(0xFF564338)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
