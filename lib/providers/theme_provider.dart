import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to hold the current ThemeMode. Defaults to ThemeMode.system.
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
