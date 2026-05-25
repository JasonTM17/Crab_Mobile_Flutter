import 'package:flutter/material.dart';

import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_theme.dart';

class GradientButton extends StatefulWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.gradient,
    this.height = 56,
    this.borderRadius = AppRadii.md,
    this.glow,
    this.loading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final LinearGradient? gradient;
  final double height;
  final double borderRadius;
  final List<BoxShadow>? glow;
  final bool loading;
  final bool expand;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.fast,
      lowerBound: 0,
      upperBound: 1,
    );
    _scale = Tween<double>(
      begin: 1,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: AppMotion.emphasis));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _down(TapDownDetails _) => _controller.forward();
  void _up(TapUpDetails _) => _controller.reverse();
  void _cancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disabled = widget.onPressed == null || widget.loading;
    final gradient = widget.gradient ?? AppGradients.primary;
    final glow = widget.glow ?? AppShadows.shadowGlow;
    final radius = BorderRadius.circular(widget.borderRadius);

    final body = AnimatedBuilder(
      animation: _scale,
      builder: (context, child) {
        return Transform.scale(scale: _scale.value, child: child);
      },
      child: Opacity(
        opacity: disabled ? 0.6 : 1,
        child: Container(
          height: widget.height < 52 ? 52 : widget.height,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: radius,
            border: Border.all(
              color: Colors.white.withValues(alpha: disabled ? 0.08 : 0.14),
            ),
            boxShadow: disabled ? null : glow,
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: widget.loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Row(
                  mainAxisSize:
                      widget.expand ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: Colors.white, size: 18),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    Text(
                      widget.label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );

    final tappable = GestureDetector(
      onTapDown: disabled ? null : _down,
      onTapUp: disabled ? null : _up,
      onTapCancel: disabled ? null : _cancel,
      onTap: disabled ? null : widget.onPressed,
      child: body,
    );

    return widget.expand
        ? SizedBox(width: double.infinity, child: tappable)
        : tappable;
  }
}
