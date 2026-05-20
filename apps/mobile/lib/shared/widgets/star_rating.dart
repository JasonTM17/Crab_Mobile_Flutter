import 'package:flutter/material.dart';

const _kDefaultStarColor = Color(0xFFFBBF24);

class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.rating,
    this.max = 5,
    this.size = 18,
    this.showCount = false,
    this.count,
    this.color,
  });

  final double rating;
  final int max;
  final double size;
  final bool showCount;
  final int? count;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final starColor = color ?? _kDefaultStarColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < max; i++) _buildStar(i, starColor),
        if (showCount && count != null) ...[
          const SizedBox(width: 4),
          Text(
            '($count)',
            style: TextStyle(
              fontSize: size * 0.72,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStar(int index, Color starColor) {
    final fill = (rating - index).clamp(0.0, 1.0);
    IconData icon;
    if (fill >= 0.75) {
      icon = Icons.star_rounded;
    } else if (fill >= 0.25) {
      icon = Icons.star_half_rounded;
    } else {
      icon = Icons.star_outline_rounded;
    }

    return Icon(icon, size: size, color: starColor);
  }
}

class InteractiveStarRating extends StatelessWidget {
  const InteractiveStarRating({
    super.key,
    required this.rating,
    required this.onChanged,
    this.max = 5,
    this.size = 32,
    this.color,
  });

  final double rating;
  final ValueChanged<double> onChanged;
  final int max;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final starColor = color ?? _kDefaultStarColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(max, (index) {
        final filled = index < rating.round();
        return GestureDetector(
          onTap: () => onChanged((index + 1).toDouble()),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              size: size,
              color: starColor,
            ),
          ),
        );
      }),
    );
  }
}
