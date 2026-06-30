import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Neon Space Theme
  static const Color cyanNeon = Color(0xFF00F0FF);
  static const Color purpleNeon = Color(0xFFB537F2);
  static const Color acidGreen = Color(0xFF39FF14);
  
  // Secondary Colors
  static const Color orangeNeon = Color(0xFFFF6B35);
  static const Color errorRed = Color(0xFFFF0033);
  
  // Background Colors
  static const Color deepSpaceDark = Color(0xFF0A0E27);
  static const Color bgPrimary = Color(0xFF0F1629);
  static const Color bgSecondary = Color(0xFF1A2238);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0A9B8);
  static const Color textTertiary = Color(0xFF6B7280);
  
  // Other Colors
  static const Color dividerColor = Color(0xFF2D3748);
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningYellow = Color(0xFFFCD34D);
  
  // Gradients
  static const LinearGradient neonGradient = LinearGradient(
    colors: [cyanNeon, purpleNeon],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}