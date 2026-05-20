import 'package:flutter/material.dart';

import '../../core/theme/app_motion.dart';

class AnimatedDotIndicator extends StatelessWidget {
  const AnimatedDotIndicator({
    super.key,
    required this.count,
    required this.activeIndex,
    this.activeColor,
    this.inactiveColor,
    this.dotSize = 6,
    this.activeWidth = 22,
    this.spacing = 6,
  });

  final int count;
  final int activeIndex;
  final Color? activeColor;
  final Color? inactiveColor;
  final double dotSize;
  final double activeWidth;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = activeColor ?? theme.colorScheme.primary;
    final inactive =
        inactiveColor ?? theme.colorScheme.onSurface.withValues(alpha: 0.18);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final isActive = i == activeIndex;
        return AnimatedContainer(
          duration: AppMotion.normal,
          curve: AppMotion.standard,
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          width: isActive ? activeWidth : dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: isActive ? active : inactive,
            borderRadius: BorderRadius.circular(dotSize),
          ),
        );
      }),
    );
  }
}
