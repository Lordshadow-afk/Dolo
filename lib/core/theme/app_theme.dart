import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.cockpitGradientStart,
      primaryColor: AppColors.mint,
      colorScheme: const ColorScheme.light(
        primary: AppColors.mint,
        secondary: AppColors.indigo,
        surface: AppColors.lightSurface,
        error: AppColors.rose,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkCockpitGradientStart,
      primaryColor: AppColors.mint,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.mint,
        secondary: AppColors.indigo,
        surface: AppColors.darkSurface,
        error: AppColors.rose,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }
}
