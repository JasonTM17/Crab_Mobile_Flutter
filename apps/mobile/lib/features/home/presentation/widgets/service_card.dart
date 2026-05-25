import 'package:flutter/material.dart';

import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_theme.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.label,
    required this.icon,
    required this.tint,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final gradientEnd = Color.lerp(tint, Colors.white, isDark ? 0.08 : 0.22)!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                tint.withValues(alpha: isDark ? 0.30 : 0.18),
                cs.surface,
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border:
                Border.all(color: tint.withValues(alpha: isDark ? 0.26 : 0.18)),
            boxShadow:
                isDark ? null : AppShadows.coloredGlow(tint, opacity: 0.16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [tint, gradientEnd],
                  ),
                  borderRadius: BorderRadius.circular(21),
                  boxShadow: AppShadows.coloredGlow(tint, opacity: 0.22),
                ),
                child: Icon(icon, color: Colors.white, size: 27),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
