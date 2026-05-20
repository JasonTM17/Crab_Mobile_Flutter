import 'package:flutter/material.dart';

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
    final scheme = Theme.of(context).colorScheme;
    final colors = _resolveColors(scheme);

    final verticalPad = dense ? 2.0 : 4.0;
    final horizontalPad = dense ? 8.0 : 12.0;
    final fontSize = dense ? 11.0 : 12.0;
    final iconSize = dense ? 12.0 : 14.0;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: verticalPad,
        horizontal: horizontalPad,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: iconSize, color: colors.foreground),
            SizedBox(width: dense ? 3 : 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: colors.foreground,
              height: 1.2,
            ),
          ),
          if (trailingDot) ...[
            SizedBox(width: dense ? 4 : 6),
            Container(
              width: 5,
              height: 5,
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
          foreground: const Color(0xFF16A34A),
          background: const Color(0xFF16A34A).withValues(alpha: 0.08),
          border: const Color(0xFF16A34A).withValues(alpha: 0.2),
        );
      case InfoChipVariant.warning:
        return _ChipColors(
          foreground: const Color(0xFFD97706),
          background: const Color(0xFFD97706).withValues(alpha: 0.08),
          border: const Color(0xFFD97706).withValues(alpha: 0.2),
        );
      case InfoChipVariant.error:
        return _ChipColors(
          foreground: const Color(0xFFDC2626),
          background: const Color(0xFFDC2626).withValues(alpha: 0.08),
          border: const Color(0xFFDC2626).withValues(alpha: 0.2),
        );
      case InfoChipVariant.brand:
        return _ChipColors(
          foreground: scheme.primary,
          background: scheme.primary.withValues(alpha: 0.08),
          border: scheme.primary.withValues(alpha: 0.2),
        );
      case InfoChipVariant.defaults:
        return _ChipColors(
          foreground: scheme.onSurfaceVariant,
          background: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
          border: scheme.outlineVariant,
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
