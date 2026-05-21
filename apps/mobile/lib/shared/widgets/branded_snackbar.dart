import 'package:flutter/material.dart';

/// Branded snackbar helpers — replaces ad-hoc `Colors.red` snackbars across
/// the app with floating, rounded, color-coded surfaces aligned with the
/// design tokens.
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
          content: Row(
            children: [
              Icon(palette.icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: palette.bg,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          duration: duration,
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
          bg: Color(0xFF15803D),
          icon: Icons.check_circle_rounded,
        );
      case SnackKind.warning:
        return const _Palette(
          bg: Color(0xFFD97706),
          icon: Icons.warning_amber_rounded,
        );
      case SnackKind.error:
        return const _Palette(
          bg: Color(0xFFDC2626),
          icon: Icons.error_rounded,
        );
      case SnackKind.info:
        return _Palette(
          bg: theme.colorScheme.primary,
          icon: Icons.info_rounded,
        );
    }
  }
}

enum SnackKind { success, info, warning, error }

class _Palette {
  final Color bg;
  final IconData icon;
  const _Palette({required this.bg, required this.icon});
}
