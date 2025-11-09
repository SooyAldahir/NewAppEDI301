// lib/src/theme_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. El Notifier global que la UI escuchará
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

const String _kThemePersistenceKey = 'theme_mode';

// 2. Carga el tema guardado al iniciar la app
Future<void> loadTheme() async {
  final prefs = await SharedPreferences.getInstance();
  final String? themeName = prefs.getString(_kThemePersistenceKey);

  if (themeName == 'dark') {
    themeNotifier.value = ThemeMode.dark;
  } else if (themeName == 'light') {
    themeNotifier.value = ThemeMode.light;
  } else {
    // Por defecto, sigue la configuración del sistema
    themeNotifier.value = ThemeMode.system;
  }
}

// 3. Guarda el tema cuando el usuario lo cambia
Future<void> setTheme(ThemeMode mode) async {
  themeNotifier.value = mode;
  final prefs = await SharedPreferences.getInstance();

  String themeName;
  if (mode == ThemeMode.dark) {
    themeName = 'dark';
  } else if (mode == ThemeMode.light) {
    themeName = 'light';
  } else {
    themeName = 'system';
  }
  await prefs.setString(_kThemePersistenceKey, themeName);
}
