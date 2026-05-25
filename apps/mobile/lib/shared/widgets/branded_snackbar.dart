import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class BrandedSnack {
  const BrandedSnack._();

  static void show(
    BuildContext context, {
    required String message,
    SnackKind kind = SnackKind.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final theme = Theme.of(context);
    final palette = _palette(theme, kind);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: palette.background,
          duration: duration,
          content: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(palette.icon, color: Colors.white, size: 16),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          margin: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.md,
          ),
          action: (actionLabel != null && onAction != null)
              ? SnackBarAction(
                  label: actionLabel,
                  textColor: Colors.white,
                  onPressed: onAction,
                )
              : null,
        ),
      );
  }

  static void success(BuildContext context, String message) =>
      show(context, message: message, kind: SnackKind.success);

  static void info(BuildContext context, String message) =>
      show(context, message: message, kind: SnackKind.info);

  static void warning(BuildContext context, String message) =>
      show(context, message: message, kind: SnackKind.warning);

  static void error(BuildContext context, String message) =>
      show(context, message: message, kind: SnackKind.error);

  static _Palette _palette(ThemeData theme, SnackKind kind) {
    switch (kind) {
      case SnackKind.success:
        return const _Palette(
          background: Color(0xFF15803D),
          icon: Icons.check_circle_rounded,
        );
      case SnackKind.warning:
        return const _Palette(
          background: Color(0xFFB45309),
          icon: Icons.warning_amber_rounded,
        );
      case SnackKind.error:
        return const _Palette(
          background: Color(0xFFB91C1C),
          icon: Icons.error_rounded,
        );
      case SnackKind.info:
        return _Palette(
          background: theme.colorScheme.primary,
          icon: Icons.info_rounded,
        );
    }
  }
}

enum SnackKind { success, info, warning, error }

class _Palette {
  const _Palette({required this.background, required this.icon});

  final Color background;
  final IconData icon;
}
