import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'presentation/screens/splash_screen.dart';
import 'providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(
    const ProviderScope(child: LocalMindApp()),
  );
}

class LocalMindApp extends ConsumerWidget {
  const LocalMindApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'LocalMind',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF8A3D),
          brightness: Brightness.light,
          surface: const Color(0xFFFFF8F6),
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFFFFF8F6),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFF8F6),
          elevation: 0,
          foregroundColor: Color(0xFF241914),
          surfaceTintColor: Colors.transparent,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF8A3D),
          brightness: Brightness.dark,
          surface: const Color(0xFF1E130D),
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFF140C08),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF140C08),
          elevation: 0,
          foregroundColor: Color(0xFFFFEDE5),
          surfaceTintColor: Colors.transparent,
        ),
      ),
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}
