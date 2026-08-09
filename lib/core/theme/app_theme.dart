import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        textTheme: TextTheme(
          headlineMedium: AppTextStyles.displayLarge,
          titleMedium: AppTextStyles.titleMedium,
          bodyMedium: AppTextStyles.bodyText,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        textTheme: TextTheme(
          headlineMedium: AppTextStyles.displayLarge.copyWith(color: Colors.white),
          titleMedium: AppTextStyles.titleMedium.copyWith(color: Colors.white),
          bodyMedium: AppTextStyles.bodyText.copyWith(color: Colors.white70),
        ),
      );
}