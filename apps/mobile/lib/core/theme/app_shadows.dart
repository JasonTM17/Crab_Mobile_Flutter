import 'package:flutter/material.dart';

import 'app_theme.dart';

class AppShadows {
  const AppShadows._();

  static const List<BoxShadow> shadowSoft = [
    BoxShadow(
      color: Color(0x120F172A),
      offset: Offset(0, 6),
      blurRadius: 18,
      spreadRadius: -6,
    ),
    BoxShadow(
      color: Color(0x080F172A),
      offset: Offset(0, 2),
      blurRadius: 6,
    ),
  ];

  static const List<BoxShadow> shadowElevated = [
    BoxShadow(
      color: Color(0x1A0F172A),
      offset: Offset(0, 12),
      blurRadius: 32,
      spreadRadius: -10,
    ),
    BoxShadow(
      color: Color(0x0D0F172A),
      offset: Offset(0, 4),
      blurRadius: 10,
      spreadRadius: -2,
    ),
  ];

  static final List<BoxShadow> shadowGlow = coloredGlow(AppColors.primary);

  static List<BoxShadow> coloredGlow(Color color, {double opacity = 0.24}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        offset: const Offset(0, 10),
        blurRadius: 28,
        spreadRadius: -8,
      ),
    ];
  }
}
