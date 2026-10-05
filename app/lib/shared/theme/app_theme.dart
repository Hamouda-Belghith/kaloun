import 'package:flutter/material.dart';

/// Palette et typographie puisées dans le Mosshaf lui-même : le papier
/// ivoire et l'encre des pages scannées, le rose des frises qui les
/// bordent, l'indigo et l'or de la couverture. L'interface s'efface
/// devant les pages plutôt que d'imposer un style qui leur est étranger.
class AppColors {
  AppColors._();

  static const paper = Color(0xFFF6EFDD);
  static const ink = Color(0xFF1C1A14);
  static const indigo = Color(0xFF15297D);
  static const rose = Color(0xFF9C4A54);
  static const gold = Color(0xFFA9832E);

  static const paperDark = Color(0xFF17150F);
  static const inkDark = Color(0xFFEDE6D3);
  static const indigoDark = Color(0xFF7C8FE8);
  static const roseDark = Color(0xFFCB8A93);
  static const goldDark = Color(0xFFCBA94F);
}

class AppTheme {
  /// Titres (en-têtes d'écran, nom des sourates) : koufique anguleux,
  /// l'écriture des tout premiers Corans manuscrits.
  static const _displayFont = 'ReemKufi';

  /// Texte d'interface courant (listes, boutons, dates).
  static const _bodyFont = 'Cairo';

  static TextTheme _textTheme(Color ink) {
    return TextTheme(
      titleLarge: TextStyle(fontFamily: _displayFont, color: ink, fontSize: 22),
      titleMedium: TextStyle(fontFamily: _displayFont, color: ink, fontSize: 18),
      titleSmall: TextStyle(fontFamily: _displayFont, color: ink, fontSize: 16),
      bodyLarge: TextStyle(fontFamily: _bodyFont, color: ink, fontSize: 17),
      bodyMedium: TextStyle(fontFamily: _bodyFont, color: ink, fontSize: 15),
      bodySmall: TextStyle(fontFamily: _bodyFont, color: ink, fontSize: 13),
      labelLarge: TextStyle(fontFamily: _bodyFont, color: ink, fontSize: 15),
      labelMedium: TextStyle(fontFamily: _bodyFont, color: ink, fontSize: 12),
      labelSmall: TextStyle(fontFamily: _bodyFont, color: ink, fontSize: 11),
    );
  }

  static ThemeData light() {
    const scheme = ColorScheme.light(
      primary: AppColors.indigo,
      onPrimary: AppColors.paper,
      secondary: AppColors.rose,
      onSecondary: AppColors.paper,
      tertiary: AppColors.gold,
      onTertiary: AppColors.ink,
      surface: AppColors.paper,
      onSurface: AppColors.ink,
      outline: Color(0x339C4A54), // rose, discret
      outlineVariant: Color(0x1F9C4A54),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.paper,
      fontFamily: _bodyFont,
      textTheme: _textTheme(AppColors.ink),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.indigo,
        foregroundColor: AppColors.paper,
        titleTextStyle: TextStyle(
          fontFamily: _displayFont,
          color: AppColors.paper,
          fontSize: 20,
        ),
        shape: Border(bottom: BorderSide(color: AppColors.gold, width: 1)),
      ),
      bottomAppBarTheme: const BottomAppBarThemeData(
        color: AppColors.paper,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(color: Color(0x339C4A54), space: 1),
      listTileTheme: const ListTileThemeData(iconColor: AppColors.indigo),
      textSelectionTheme:
          const TextSelectionThemeData(cursorColor: AppColors.rose),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0x4D9C4A54)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.indigo,
          foregroundColor: AppColors.paper,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  static ThemeData dark() {
    const scheme = ColorScheme.dark(
      primary: AppColors.indigoDark,
      onPrimary: AppColors.paperDark,
      secondary: AppColors.roseDark,
      onSecondary: AppColors.paperDark,
      tertiary: AppColors.goldDark,
      onTertiary: AppColors.paperDark,
      surface: AppColors.paperDark,
      onSurface: AppColors.inkDark,
      outline: Color(0x40CB8A93),
      outlineVariant: Color(0x26CB8A93),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.paperDark,
      fontFamily: _bodyFont,
      textTheme: _textTheme(AppColors.inkDark),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Color(0xFF221F16),
        foregroundColor: AppColors.inkDark,
        titleTextStyle: TextStyle(
          fontFamily: _displayFont,
          color: AppColors.inkDark,
          fontSize: 20,
        ),
        shape: Border(bottom: BorderSide(color: AppColors.goldDark, width: 1)),
      ),
      bottomAppBarTheme: const BottomAppBarThemeData(
        color: Color(0xFF221F16),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(color: Color(0x40CB8A93), space: 1),
      listTileTheme: const ListTileThemeData(iconColor: AppColors.indigoDark),
      textSelectionTheme:
          const TextSelectionThemeData(cursorColor: AppColors.roseDark),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0x4DCB8A93)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.goldDark, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.indigoDark,
          foregroundColor: AppColors.paperDark,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
