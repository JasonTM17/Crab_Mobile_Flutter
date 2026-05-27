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
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: tint.withValues(alpha: isDark ? 0.24 : 0.14),
            ),
            boxShadow: isDark ? null : AppShadows.shadowSoft,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tileSide = constraints.biggest.shortestSide;
              final horizontalPadding =
                  (constraints.maxWidth * 0.12).clamp(8.0, 12.0);
              final verticalPadding =
                  (constraints.maxHeight * 0.08).clamp(6.0, 12.0);
              final iconBoxSize = (tileSide * 0.38).clamp(34.0, 42.0);
              final iconSize = (iconBoxSize * 0.58).clamp(19.0, 24.0);
              final gap = (constraints.maxHeight * 0.04).clamp(4.0, 8.0);
              final textStyle = theme.textTheme.labelSmall?.copyWith(
                color: cs.onSurface,
                fontSize: (tileSide * 0.13).clamp(10.0, 11.0),
                fontWeight: FontWeight.w800,
                height: 1.05,
                letterSpacing: 0,
              );

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: iconBoxSize,
                      height: iconBoxSize,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [tint, gradientEnd],
                        ),
                        borderRadius: BorderRadius.circular(iconBoxSize * 0.36),
                        boxShadow: AppShadows.coloredGlow(tint, opacity: 0.22),
                      ),
                      child: Icon(icon, color: Colors.white, size: iconSize),
                    ),
                    SizedBox(height: gap),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: textStyle,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
