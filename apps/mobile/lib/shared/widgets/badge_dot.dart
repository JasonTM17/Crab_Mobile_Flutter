import 'package:flutter/material.dart';

class BadgeDot extends StatefulWidget {
  const BadgeDot({
    super.key,
    this.color,
    this.size = 10,
    this.pulse = true,
  });

  final Color? color;
  final double size;
  final bool pulse;

  @override
  State<BadgeDot> createState() => _BadgeDotState();
}

class _BadgeDotState extends State<BadgeDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _opacity = Tween<double>(begin: 1.0, end: 0.55).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.pulse) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(BadgeDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulse && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.pulse && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dotColor = widget.color ?? scheme.primary;

    final dot = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: dotColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: scheme.surface,
          width: widget.size <= 8 ? 1 : 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: dotColor.withValues(alpha: widget.pulse ? 0.26 : 0.18),
            blurRadius: widget.size,
            spreadRadius: widget.pulse ? 0.4 : 0,
          ),
        ],
      ),
    );

    if (!widget.pulse) return dot;

    return FadeTransition(opacity: _opacity, child: dot);
  }
}
