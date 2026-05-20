import 'package:flutter/material.dart';

import 'app_theme.dart';

class AppShadows {
  const AppShadows._();

  static const List<BoxShadow> shadowSoft = [
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: -2,
    ),
  ];

  static const List<BoxShadow> shadowElevated = [
    BoxShadow(
      color: Color(0x1F000000),
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: -4,
    ),
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 2),
      blurRadius: 6,
    ),
  ];

  static List<BoxShadow> shadowGlow = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.30),
      offset: const Offset(0, 8),
      blurRadius: 24,
      spreadRadius: -4,
    ),
  ];

  static List<BoxShadow> coloredGlow(Color color, {double opacity = 0.30}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        offset: const Offset(0, 8),
        blurRadius: 24,
        spreadRadius: -4,
      ),
    ];
  }
}
