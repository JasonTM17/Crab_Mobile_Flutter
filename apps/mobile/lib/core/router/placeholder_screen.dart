import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_gradients.dart';
import '../theme/app_motion.dart';
import '../../shared/widgets/gradient_button.dart';

/// Friendly placeholder shown for routes that are wired but whose UI is still
/// being built. Branded with the design system gradients + motion.
class PlaceholderScreen extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? ctaLabel;
  final String? ctaRoute;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.construction_rounded,
    this.ctaLabel,
    this.ctaRoute,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                duration: AppMotion.slow,
                curve: AppMotion.emphasis,
                tween: Tween(begin: 0.85, end: 1.0),
                builder: (_, value, child) =>
                    Transform.scale(scale: value, child: child),
                child: Container(
                  width: 116,
                  height: 116,
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withValues(alpha: 0.32),
                        blurRadius: 28,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 54, color: Colors.white),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (ctaLabel != null && ctaRoute != null)
                GradientButton(
                  label: ctaLabel!,
                  icon: Icons.east_rounded,
                  height: 54,
                  onPressed: () => context.go(ctaRoute!),
                )
              else
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text(
                    'Back',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    side: BorderSide(
                      color: cs.outlineVariant.withValues(alpha: 0.6),
                      width: 1.4,
                    ),
                    foregroundColor: cs.onSurface,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
