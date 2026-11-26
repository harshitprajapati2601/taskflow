import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {

  AppColors._();

  static const primary = Color(0xFF5B4BDB);
  static const accent = Color(0xFF14B8A6);
  static const warning = Color(0xFFF97316);
  static const danger = Color(0xFFEF4444);
}

class AppTheme {
// Named Private Constructor
//In short, it stops anyone from creating an object
// (new AppTheme() or AppTheme()) of AppTheme,
// allowing you to access its static themes
// (like AppTheme.lightTheme or AppTheme.darkTheme)
// directly without instantiating the class.
  AppTheme._(); //// Prevents `AppTheme()` instantiation

static ThemeData get light => _build(Brightness.light);
static ThemeData get dark => _build(Brightness.dark);

static ThemeData _build(Brightness brightness){

  final scheme =ColorScheme.fromSeed(
      seedColor: AppColors.primary,
          brightness: brightness
  );
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
      colorScheme: scheme
  );

  OutlineInputBorder border(Color color,  [double width = 0]){
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: width == 0
          ? BorderSide.none
          : BorderSide(color: color,width: width),
    );
  }

  return base.copyWith(
    textTheme:
      GoogleFonts.interTextTheme(base.textTheme),
    scaffoldBackgroundColor: brightness == Brightness.light
        ? const Color(0xFFF6F7B)
        : null,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
    ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: border(scheme.outline),
        enabledBorder: border(scheme.outline),
        focusedBorder: border(scheme.primary, 1.5),
        errorBorder: border(scheme.error, 1),
        focusedErrorBorder: border(scheme.error, 1.5),
      ),
  );
}
}