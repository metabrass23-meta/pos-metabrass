import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

/// Defines the theme for the Elegant Bridal POS application.
class AppTheme {
  static ThemeData get theme => ThemeData(
    primaryColor: const Color(0xFFF5E6D3), // Elegant Ivory
    scaffoldBackgroundColor: const Color(0xFFF5E6D3),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 24.sp,
        color: const Color(0xFF2C2C2C), // Deep Charcoal
        fontWeight: FontWeight.bold,
      ),
      bodyMedium: GoogleFonts.roboto(
        fontSize: 12.sp,
        color: const Color(0xFF2C2C2C),
      ),
      labelLarge: GoogleFonts.greatVibes(
        fontSize: 16.sp,
        color: const Color(0xFFD4AF37), // Soft Gold
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD4AF37), // Soft Gold
        foregroundColor: const Color(0xFF2C2C2C),
        textStyle: GoogleFonts.roboto(fontSize: 12.sp),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFC0C0C0).withOpacity(0.2), // Muted Silver
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      labelStyle: GoogleFonts.roboto(fontSize: 10.sp, color: const Color(0xFF2C2C2C)),
    ),
  );
}