import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.borderRadius = AppRadii.lg,
    this.blur = 16,
    this.tint,
    this.borderColor,
    this.shadows,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blur;
  final Color? tint;
  final Color? borderColor;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final fill = tint ?? scheme.surface.withValues(alpha: isDark ? 0.78 : 0.9);
    final border = borderColor ??
        scheme.outlineVariant.withValues(alpha: isDark ? 0.55 : 0.85);

    final radius = BorderRadius.circular(borderRadius);
    final card = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: radius,
            border: Border.all(color: border, width: 1),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );

    final shadowed = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: shadows ??
            (isDark ? AppShadows.shadowSoft : AppShadows.shadowElevated),
      ),
      child: card,
    );

    if (onTap == null) return shadowed;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: shadowed,
      ),
    );
  }
}
