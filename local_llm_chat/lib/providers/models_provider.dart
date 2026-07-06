import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/ollama_repository.dart';
import '../data/repositories/ollama_repository_impl.dart';
import '../data/repositories/gemini_repository_impl.dart';
import 'connectivity_provider.dart';

final ollamaRepositoryProvider = Provider<OllamaRepository>(
  (ref) => OllamaRepositoryImpl(),
);

final geminiRepositoryProvider = Provider<OllamaRepository>(
  (ref) => GeminiRepositoryImpl(),
);

/// Returns the correct repository based on selected model
final activeRepositoryProvider = Provider<OllamaRepository>((ref) {
  final selected = ref.watch(selectedModelProvider);
  if (_isGeminiModel(selected)) {
    return ref.watch(geminiRepositoryProvider);
  }
  return ref.watch(ollamaRepositoryProvider);
});

bool _isGeminiModel(String model) => model.startsWith('gemini-');

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

    return [...ollamaModels, ...geminiModels];
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}

/// Provider holding the currently selected model name
final selectedModelProvider = StateProvider<String>((ref) {
  final modelsAsync = ref.watch(modelsProvider);
  return modelsAsync.maybeWhen(
    data: (models) => models.isNotEmpty ? models.first : '',
    orElse: () => '',
  );
});
