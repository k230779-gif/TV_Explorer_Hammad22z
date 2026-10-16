import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF0E0B1F);
  static const Color surface = Color(0xFF16122B);
  static const Color card = Color(0xFF221D3D);
  static const Color primary = Color(0xFF7C4DFF);
  static const Color star = Color(0xFFFFC107);
  static const Color textSecondary = Color(0xFF9E9BB8);
  static const Color danger = Color(0xFFFF4D6D);

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(primary: primary, surface: surface),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: surface,
          indicatorColor: primary.withValues(alpha: 0.3),
        ),
        snackBarTheme:
            const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      );
}