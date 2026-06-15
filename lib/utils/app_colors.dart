// lib/utils/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  static const verde = Color(0xFF4CAF50);
  static const verdeEscuro = Color(0xFF388E3C);
  static const fundo = Colors.black;
  static const card = Color(0xFF1C2333);
  static const cardClaro = Color(0xFF2A3550);
  static const azulEscuro = Color(0xFF1A1A2E);
  static const cinza = Colors.grey;
  static const azulInfo = Color(0xFF4FC3F7);
  static const laranja = Color(0xFFFF9800);
  static const azul = Color(0xFF2196F3);
}

ThemeData appTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.fundo,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.verde,
      brightness: Brightness.dark,
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.verde,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      hintStyle: const TextStyle(color: Colors.grey),
      labelStyle: const TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[800]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.verde),
      ),
    ),
    useMaterial3: true,
  );
}
