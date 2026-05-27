import 'package:flutter/material.dart';

import 'app_theme.dart';

class AppGradients {
  const AppGradients._();

  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF22C86B), AppColors.primary, AppColors.primaryDark],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient primarySoft = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF7FFF9), Color(0xFFEAF7EF)],
  );

  static const LinearGradient sunset = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB800), Color(0xFFFF6B6B)],
  );

  static const LinearGradient ocean = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2196F3), Color(0xFF00BCD4)],
  );

  static const LinearGradient violet = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
  );

  static const LinearGradient walletHero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1AC86D), AppColors.primary, AppColors.primaryDark],
    stops: [0.0, 0.56, 1.0],
  );

  static const LinearGradient shimmerLight = LinearGradient(
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
    colors: [
      Color(0xFFEDEFF3),
      Color(0xFFF8F9FB),
      Color(0xFFEDEFF3),
    ],
    stops: [0.1, 0.5, 0.9],
  );

  static const LinearGradient shimmerDark = LinearGradient(
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
    colors: [
      Color(0xFF1F2937),
      Color(0xFF2D3748),
      Color(0xFF1F2937),
    ],
    stops: [0.1, 0.5, 0.9],
  );
}
