import 'package:flutter/material.dart';

abstract final class ArenaTheme {
  static const ink = Color(0xFF11162B);
  static const navy = Color(0xFF1A2242);
  static const violet = Color(0xFF5445D8);
  static const purple = Color(0xFF7C5CFC);
  static const cream = Color(0xFFFFF9EE);
  static const gold = Color(0xFFFFC44D);
  static const coral = Color(0xFFFF6978);
  static const mint = Color(0xFF45D6A4);
  static const sky = Color(0xFF53B8FF);
  static const muted = Color(0xFF9299B3);

  static const pageGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10152A), Color(0xFF1D2850), Color(0xFF171A35)],
  );

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: violet,
      brightness: Brightness.dark,
      primary: purple,
      secondary: gold,
      surface: navy,
      onSurface: Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: ink,
      fontFamily: 'Avenir Next',
      splashFactory: InkSparkle.splashFactory,
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontSize: 38,
          height: .98,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.8,
          color: Colors.white,
        ),
        headlineLarge: TextStyle(
          fontSize: 30,
          height: 1.05,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.1,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          height: 1.08,
          fontWeight: FontWeight.w900,
          letterSpacing: -.6,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w800,
          letterSpacing: -.2,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.45,
          color: Color(0xFFD9DDF0),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.4,
          color: Color(0xFFABB2CC),
        ),
        labelLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          letterSpacing: .2,
          color: Colors.white,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Avenir Next',
          fontSize: 19,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: Colors.white.withValues(alpha: .07),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: .1)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: purple,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.white.withValues(alpha: .08),
          disabledForegroundColor: Colors.white38,
          minimumSize: const Size.fromHeight(58),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: .25,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(19),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withValues(alpha: .15)),
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: .08),
          foregroundColor: Colors.white,
          minimumSize: const Size(46, 46),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: purple,
        inactiveTrackColor: Colors.white.withValues(alpha: .1),
        thumbColor: Colors.white,
        overlayColor: purple.withValues(alpha: .18),
      ),
      dividerColor: Colors.white.withValues(alpha: .08),
    );
  }
}
