import 'package:flutter/material.dart';

/// Branded snackbar helpers — replaces ad-hoc `Colors.red` snackbars across
/// the app with floating, rounded, color-coded surfaces aligned with the
/// design tokens.
class BrandedSnack {
  const BrandedSnack._();

  static void show(
    BuildContext context, {
    required String message,
    _SnackKind kind = _SnackKind.info,
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
      show(context, message: message, kind: _SnackKind.success);

  static void info(BuildContext context, String message) =>
      show(context, message: message, kind: _SnackKind.info);

  static void warning(BuildContext context, String message) =>
      show(context, message: message, kind: _SnackKind.warning);

  static void error(BuildContext context, String message) =>
      show(context, message: message, kind: _SnackKind.error);

  static _Palette _palette(ThemeData theme, _SnackKind kind) {
    switch (kind) {
      case _SnackKind.success:
        return _Palette(
          bg: const Color(0xFF15803D),
          icon: Icons.check_circle_rounded,
        );
      case _SnackKind.warning:
        return _Palette(
          bg: const Color(0xFFD97706),
          icon: Icons.warning_amber_rounded,
        );
      case _SnackKind.error:
        return _Palette(
          bg: const Color(0xFFDC2626),
          icon: Icons.error_rounded,
        );
      case _SnackKind.info:
        return _Palette(
          bg: theme.colorScheme.primary,
          icon: Icons.info_rounded,
        );
    }
  }
}

enum _SnackKind { success, info, warning, error }

class _Palette {
  final Color bg;
  final IconData icon;
  const _Palette({required this.bg, required this.icon});
}
