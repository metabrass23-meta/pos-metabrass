import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class AppTheme {
  // Color Palette
  static const Color primaryMaroon = Color(0xFF800020);
  static const Color secondaryMaroon = Color(0xFF9B0030);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color creamWhite = Color(0xFFFFFBF5);
  static const Color charcoalGray = Color(0xFF2C2C2C);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color shadowColor = Color(0x1A000000);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryMaroon,
      scaffoldBackgroundColor: creamWhite,
      fontFamily: GoogleFonts.inter().fontFamily,

      colorScheme: const ColorScheme.light(
        primary: primaryMaroon,
        secondary: accentGold,
        surface: pureWhite,
        background: creamWhite,
        onPrimary: pureWhite,
        onSecondary: charcoalGray,
        onSurface: charcoalGray,
        onBackground: charcoalGray,
      ),

      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 4.sp, // Responsive font size
          fontWeight: FontWeight.w700,
          color: charcoalGray,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 3.5.sp, // Responsive font size
          fontWeight: FontWeight.w600,
          color: charcoalGray,
          letterSpacing: -0.3,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 3.sp, // Responsive font size
          fontWeight: FontWeight.w600,
          color: charcoalGray,
          letterSpacing: -0.2,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 2.5.sp, // Responsive font size
          fontWeight: FontWeight.w500,
          color: charcoalGray,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 2.2.sp, // Responsive font size
          fontWeight: FontWeight.w500,
          color: charcoalGray,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 2.sp, // Responsive font size
          fontWeight: FontWeight.w400,
          color: charcoalGray,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 1.8.sp, // Responsive font size
          fontWeight: FontWeight.w400,
          color: charcoalGray,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 1.8.sp, // Responsive font size
          fontWeight: FontWeight.w500,
          color: charcoalGray,
          letterSpacing: 0.1,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryMaroon,
          foregroundColor: pureWhite,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(1.5.w), // Responsive border radius
          ),
          padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.w), // Responsive padding
          textStyle: GoogleFonts.inter(
            fontSize: 1.8.sp, // Responsive font size
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: pureWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(1.5.w), // Responsive border radius
          borderSide: BorderSide(color: const Color(0xFFE0E0E0), width: 0.1.w), // Responsive border width
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(1.5.w),
          borderSide: BorderSide(color: const Color(0xFFE0E0E0), width: 0.1.w),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(1.5.w),
          borderSide: BorderSide(color: primaryMaroon, width: 0.2.w), // Responsive border width
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(1.5.w),
          borderSide: BorderSide(color: Colors.red, width: 0.1.w),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w), // Responsive padding
        hintStyle: GoogleFonts.inter(
          color: const Color(0xFF9E9E9E),
          fontSize: 1.8.sp, // Responsive font size
          fontWeight: FontWeight.w400,
        ),
        labelStyle: GoogleFonts.inter(
          color: charcoalGray,
          fontSize: 1.8.sp, // Responsive font size
          fontWeight: FontWeight.w500,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 8,
        shadowColor: shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.w), // Responsive border radius
        ),
        color: pureWhite,
      ),
    );
  }

  static ThemeData get darkTheme {
    return lightTheme.copyWith(
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      colorScheme: const ColorScheme.dark(
        primary: primaryMaroon,
        secondary: accentGold,
        surface: Color(0xFF2C2C2C),
        background: Color(0xFF1A1A1A),
        onPrimary: pureWhite,
        onSecondary: pureWhite,
        onSurface: pureWhite,
        onBackground: pureWhite,
      ),
    );
  }
}