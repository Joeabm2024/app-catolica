import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get displayLarge => GoogleFonts.merriweather(
        fontSize: 28,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get titleMedium => GoogleFonts.lato(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get bodyText => GoogleFonts.lato(
        fontSize: 15,
        fontWeight: FontWeight.normal,
        height: 1.5,
      );
}