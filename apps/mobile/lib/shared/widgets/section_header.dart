import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Reusable section header with bold title, optional leading icon dot,
/// and optional trailing "See all" button.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
    this.seeAllLabel = 'See all',
    this.leadingDotColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  final String title;
  final VoidCallback? onSeeAll;
  final String seeAllLabel;
  final Color? leadingDotColor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dotColor = leadingDotColor ?? AppColors.primary;

    return Padding(
      padding: padding,
      child: Row(
        children: [
          // Leading dot indicator
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          // Title
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Trailing action
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    seeAllLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
