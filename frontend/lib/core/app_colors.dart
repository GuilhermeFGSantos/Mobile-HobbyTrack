import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleLight = Color(0xFFEDE7FF);
  static const Color green = Color(0xFF43A047);
  static const Color greenLight = Color(0xFFE8F5E9);
  static const Color orange = Color(0xFFFF7A00);
  static const Color peach = Color(0xFFFFECE0);
  static const Color lavender = Color(0xFFEDE7FF);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA000);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color background = Color(0xFFFAF0E8);
  static const Color cardCream = Color(0xFFFDF5EC);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color white = Colors.white;

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF8A44D4), Color(0xFF6B21A8)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFF8A44D4)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF8A44D4), Color(0xFFE8507A), Color(0xFFF97316)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
