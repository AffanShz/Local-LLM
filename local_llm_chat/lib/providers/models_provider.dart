import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/ollama_repository.dart';
import '../data/repositories/ollama_repository_impl.dart';
import '../data/repositories/gemini_repository_impl.dart';
import '../data/repositories/claude_repository_impl.dart';
import 'connectivity_provider.dart';

final ollamaRepositoryProvider = Provider<OllamaRepository>(
  (ref) => OllamaRepositoryImpl(),
);

final geminiRepositoryProvider = Provider<OllamaRepository>(
  (ref) => GeminiRepositoryImpl(),
);

final claudeRepositoryProvider = Provider<OllamaRepository>(
  (ref) => ClaudeRepositoryImpl(),
);

/// Returns the correct repository based on selected model
final activeRepositoryProvider = Provider<OllamaRepository>((ref) {
  final selected = ref.watch(selectedModelProvider);
  if (_isGeminiModel(selected)) {
    return ref.watch(geminiRepositoryProvider);
  }
  if (_isClaudeModel(selected)) {
    return ref.watch(claudeRepositoryProvider);
  }
  return ref.watch(ollamaRepositoryProvider);
});

bool _isGeminiModel(String model) => model.startsWith('gemini-');
bool _isClaudeModel(String model) => model.startsWith('claude-');

/// Provides the list of available models — Ollama locals + Gemini if online.
final modelsProvider = AsyncNotifierProvider<ModelsNotifier, List<String>>(
  ModelsNotifier.new,
);

class ModelsNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    final ollamaRepo = ref.watch(ollamaRepositoryProvider);
    final isOnline = ref.watch(isOnlineProvider);

    List<String> ollamaModels = [];
    try {
      ollamaModels = await ollamaRepo.getAvailableModels();
    } catch (_) {
      // Ollama offline — continue with empty list
    }

    final geminiModels = isOnline
        ? await GeminiRepositoryImpl().getAvailableModels()
        : <String>[];

    final claudeModels = isOnline
        ? await ClaudeRepositoryImpl().getAvailableModels()
        : <String>[];

    return [...ollamaModels, ...geminiModels, ...claudeModels];
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}

/// Provider holding the currently selected model name
final selectedModelProvider = StateProvider<String>((ref) => '');

/// Keeps selectedModel in sync when models first load — sets to first model
/// only if nothing has been selected yet (preserves user's manual choice).
final selectedModelSyncProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<List<String>>>(modelsProvider, (_, next) {
    next.whenData((models) {
      if (models.isEmpty) return;
      final current = ref.read(selectedModelProvider);
      if (current.isEmpty || !models.contains(current)) {
        ref.read(selectedModelProvider.notifier).state = models.first;
      }
    });
  });
});
