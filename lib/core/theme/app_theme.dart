// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // ================== Brand Colors ==================
  static const Color bgStart = Color(0xFF081A36);
  static const Color bgEnd = Color(0xFF040D1D);

  static const Color panel = Color(0xFF143F7C);
  static const Color panelTop = Color(0xFF1B4F9C);

  static const Color accent = Color(0xFF1B4F9C);
  static const Color accentDark = Color(0xFF10386B);
  static const Color accentSoft = Color(0xFFE7EEF9);

  static const Color textLight = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFFC9D6EA);
  static const Color hint = Color(0xFF93A9C9);

  static const Color line = Color(0xFF29496F);
  static const Color ink = Color(0xFFF2F6FB);
  static const Color inkSoft = Color(0xFF93A9C9);

  static const Color danger = Color(0xFFFF4C57);

  // ================== Gradients ==================
  static const LinearGradient aquaCreamGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF17345F),
      Color(0xFF143F7C),
      Color(0xFF1B4F9C),
    ],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient ctaAquaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1B4F99),
      Color(0xFF245AA6),
      Color(0xFF153F78),
    ],
    stops: [0.0, 0.50, 1.0],
  );

  static const LinearGradient premiumAppBarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1D4F99),
      Color(0xFF163F7E),
      Color(0xFF0E2D60),
    ],
  );

  static const LinearGradient darkGlassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF17345F),
      Color(0xFF122B50),
      Color(0xFF0D2140),
    ],
  );

  static const LinearGradient panelGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF17345F),
      Color(0xFF122B50),
    ],
  );

  // ================== Light Theme ==================
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: accent,
        scaffoldBackgroundColor: ink,
        fontFamily: "Montserrat",
        colorScheme: const ColorScheme.light(
          primary: accent,
          secondary: panelTop,
          surface: Colors.white,
          error: danger,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFF0D2140),
          onError: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: panelTop,
          foregroundColor: Colors.white,
          elevation: 0.4,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: "Montserrat",
          ),
        ),
        dividerColor: line,
        iconTheme: const IconThemeData(
          color: accent,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 3,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: accent,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontFamily: "Montserrat",
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: accent,
            side: const BorderSide(color: accent, width: 1.2),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontFamily: "Montserrat",
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: accent,
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontFamily: "Montserrat",
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: const TextStyle(
            color: hint,
            fontFamily: "Montserrat",
          ),
          labelStyle: const TextStyle(
            color: Color(0xFF163F7E),
            fontFamily: "Montserrat",
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: line, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: accent, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: danger, width: 1.2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: danger, width: 1.5),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: accent,
          unselectedItemColor: inkSoft,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: accentSoft,
          selectedColor: accent,
          disabledColor: Colors.grey.shade200,
          secondarySelectedColor: accent,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          labelStyle: const TextStyle(
            color: Color(0xFF0D2140),
            fontWeight: FontWeight.w600,
            fontFamily: "Montserrat",
          ),
          secondaryLabelStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontFamily: "Montserrat",
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: const BorderSide(color: line),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: panel,
          contentTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontFamily: "Montserrat",
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          behavior: SnackBarBehavior.floating,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: accent,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: accent,
          foregroundColor: Colors.white,
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: accent,
          textColor: Color(0xFF0D2140),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: Color(0xFF0D2140),
            fontWeight: FontWeight.w800,
            fontFamily: "Montserrat",
          ),
          headlineMedium: TextStyle(
            color: Color(0xFF0D2140),
            fontWeight: FontWeight.w800,
            fontFamily: "Montserrat",
          ),
          titleLarge: TextStyle(
            color: Color(0xFF0D2140),
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: "Montserrat",
          ),
          titleMedium: TextStyle(
            color: Color(0xFF163F7E),
            fontWeight: FontWeight.w700,
            fontFamily: "Montserrat",
          ),
          bodyLarge: TextStyle(
            color: Color(0xFF0D2140),
            fontFamily: "Montserrat",
          ),
          bodyMedium: TextStyle(
            color: Color(0xFF29496F),
            fontFamily: "Montserrat",
          ),
          bodySmall: TextStyle(
            color: inkSoft,
            fontFamily: "Montserrat",
          ),
        ),
      );

  // ================== Dark Theme ==================
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: accent,
        scaffoldBackgroundColor: bgEnd,
        fontFamily: "Montserrat",
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: panelTop,
          surface: Color(0xFF122B50),
          error: danger,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onError: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: panel,
          foregroundColor: Colors.white,
          elevation: 0.3,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: "Montserrat",
          ),
        ),
        dividerColor: Colors.white12,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF122B50),
          elevation: 3,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: accent,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontFamily: "Montserrat",
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white24, width: 1.2),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontFamily: "Montserrat",
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: muted,
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontFamily: "Montserrat",
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF17345F),
          hintStyle: const TextStyle(
            color: muted,
            fontFamily: "Montserrat",
          ),
          labelStyle: const TextStyle(
            color: Color(0xFFC9D6EA),
            fontFamily: "Montserrat",
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.white12, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: accent, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: danger, width: 1.2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: danger, width: 1.5),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF122B50),
          selectedItemColor: Colors.white,
          unselectedItemColor: Color(0xFF93A9C9),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.white10,
          selectedColor: accent,
          disabledColor: Colors.white10,
          secondarySelectedColor: accent,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          labelStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontFamily: "Montserrat",
          ),
          secondaryLabelStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontFamily: "Montserrat",
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: const BorderSide(color: Colors.white12),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: panel,
          contentTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontFamily: "Montserrat",
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          behavior: SnackBarBehavior.floating,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: accent,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: accent,
          foregroundColor: Colors.white,
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: Colors.white,
          textColor: Colors.white,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontFamily: "Montserrat",
          ),
          headlineMedium: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontFamily: "Montserrat",
          ),
          titleLarge: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: "Montserrat",
          ),
          titleMedium: TextStyle(
            color: Color(0xFFC9D6EA),
            fontWeight: FontWeight.w700,
            fontFamily: "Montserrat",
          ),
          bodyLarge: TextStyle(
            color: Colors.white,
            fontFamily: "Montserrat",
          ),
          bodyMedium: TextStyle(
            color: Color(0xFFC9D6EA),
            fontFamily: "Montserrat",
          ),
          bodySmall: TextStyle(
            color: Color(0xFF93A9C9),
            fontFamily: "Montserrat",
          ),
        ),
      );
}
