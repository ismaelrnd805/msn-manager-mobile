import 'package:flutter/material.dart';

/// Couleurs de marque MSN — palette « Bleu + Cyan » choisie pour l'app.
class MsnColors {
  MsnColors._();

  static const Color primary = Color(0xFF0B4FA8);
  static const Color primaryDark = Color(0xFF083B7F);
  static const Color accent = Color(0xFF00B8D4);
  static const Color accentSoft = Color(0xFFE0F7FB);

  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF9A825);
  static const Color danger = Color(0xFFC62828);
  static const Color info = Color(0xFF0277BD);

  static const Color surface = Color(0xFFF6F8FB);
  static const Color card = Colors.white;
  static const Color border = Color(0xFFE1E7EF);
  static const Color textPrimary = Color(0xFF16222F);
  static const Color textSecondary = Color(0xFF5B6B7C);
}

/// Thème Material 3 de l'application.
class MsnTheme {
  MsnTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.light(
      primary: MsnColors.primary,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFD6E4FB),
      onPrimaryContainer: Color(0xFF0A2A55),
      secondary: MsnColors.accent,
      onSecondary: Colors.white,
      secondaryContainer: MsnColors.accentSoft,
      onSecondaryContainer: const Color(0xFF08424D),
      surface: MsnColors.card,
      onSurface: MsnColors.textPrimary,
      surfaceContainerHighest: MsnColors.surface,
      onSurfaceVariant: MsnColors.textSecondary,
      error: MsnColors.danger,
      onError: Colors.white,
      outline: MsnColors.border,
      outlineVariant: MsnColors.border,
    );

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);

    return base.copyWith(
      scaffoldBackgroundColor: MsnColors.surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: MsnColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: MsnColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: MsnColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MsnColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MsnColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MsnColors.primary, width: 1.4),
        ),
        labelStyle: const TextStyle(color: MsnColors.textSecondary, fontSize: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: MsnColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 46),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: MsnColors.primary,
          minimumSize: const Size(48, 46),
          side: const BorderSide(color: MsnColors.primary),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: MsnColors.primary),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: MsnColors.border),
        ),
        labelStyle: const TextStyle(fontSize: 12),
      ),
      dividerTheme: const DividerThemeData(color: MsnColors.border, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: MsnColors.textPrimary,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFD6E4FB),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? MsnColors.primary : MsnColors.textSecondary,
          );
        }),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        iconColor: MsnColors.primary,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: MsnColors.primary,
        foregroundColor: Colors.white,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }
}
