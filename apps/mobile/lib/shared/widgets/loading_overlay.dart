import 'package:flutter/material.dart';

import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_motion.dart';

/// Full-screen branded loading overlay. Use sparingly for destructive
/// async operations where the user must wait (payment confirm, order place).
///
/// Usage:
/// ```dart
/// showDialog(
///   context: context,
///   barrierDismissible: false,
///   barrierColor: Colors.black.withValues(alpha: 0.45),
///   builder: (_) => const LoadingOverlay(message: 'Placing order'),
/// );
/// ```
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.zero,
      child: Center(
        child: Container(
          width: 140,
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.20),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _GradientSpinner(),
              if (message != null) ...[
                const SizedBox(height: 12),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientSpinner extends StatefulWidget {
  const _GradientSpinner();
  @override
  State<_GradientSpinner> createState() => _GradientSpinnerState();
}

class _GradientSpinnerState extends State<_GradientSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: AppMotion.slow + const Duration(milliseconds: 200),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Transform.rotate(
        angle: _c.value * 6.283185,
        child: Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: [
                Color(0xFF00B14F),
                Color(0xFF4CD787),
                Color(0xFF00B14F),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Center(
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Center(
                child: SizedBox(
                  width: 12,
                  height: 12,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper to show + dismiss the overlay imperatively.
class LoadingOverlayController {
  static void show(BuildContext context, {String? message}) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => LoadingOverlay(message: message),
    );
  }

  static void hide(BuildContext context) {
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}
