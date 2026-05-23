import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

enum InfoChipVariant { defaults, success, warning, error, brand }

class InfoChip extends StatelessWidget {
  const InfoChip({
    super.key,
    required this.label,
    this.icon,
    this.variant = InfoChipVariant.defaults,
    this.dense = false,
    this.trailingDot = false,
  });

  final String label;
  final IconData? icon;
  final InfoChipVariant variant;
  final bool dense;
  final bool trailingDot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = _resolveColors(scheme);

    final verticalPad = dense ? 4.0 : 6.0;
    final horizontalPad = dense ? 10.0 : 12.0;
    final iconSize = dense ? 12.0 : 14.0;

    return Container(
      constraints: BoxConstraints(minHeight: dense ? 24 : 30),
      padding: EdgeInsets.symmetric(
        vertical: verticalPad,
        horizontal: horizontalPad,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: iconSize, color: colors.foreground),
            SizedBox(width: dense ? 4 : 6),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (trailingDot) ...[
            SizedBox(width: dense ? 5 : 7),
            Container(
              width: dense ? 5 : 6,
              height: dense ? 5 : 6,
              decoration: BoxDecoration(
                color: colors.foreground,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }

  _ChipColors _resolveColors(ColorScheme scheme) {
    switch (variant) {
      case InfoChipVariant.success:
        return _ChipColors(
          foreground: const Color(0xFF15803D),
          background: const Color(0xFF16A34A).withValues(alpha: 0.1),
          border: const Color(0xFF16A34A).withValues(alpha: 0.22),
        );
      case InfoChipVariant.warning:
        return _ChipColors(
          foreground: const Color(0xFFB45309),
          background: const Color(0xFFD97706).withValues(alpha: 0.1),
          border: const Color(0xFFD97706).withValues(alpha: 0.2),
        );
      case InfoChipVariant.error:
        return _ChipColors(
          foreground: const Color(0xFFB91C1C),
          background: const Color(0xFFDC2626).withValues(alpha: 0.1),
          border: const Color(0xFFDC2626).withValues(alpha: 0.2),
        );
      case InfoChipVariant.brand:
        return _ChipColors(
          foreground: scheme.primary,
          background: scheme.primary.withValues(alpha: 0.1),
          border: scheme.primary.withValues(alpha: 0.2),
        );
      case InfoChipVariant.defaults:
        return _ChipColors(
          foreground: scheme.onSurfaceVariant,
          background: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
          border: scheme.outlineVariant.withValues(alpha: 0.8),
        );
    }
  }
}

class _ChipColors {
  const _ChipColors({
    required this.foreground,
    required this.background,
    required this.border,
  });

  final Color foreground;
  final Color background;
  final Color border;
}
