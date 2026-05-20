import 'package:flutter/material.dart';

import '../../core/theme/app_gradients.dart';
import 'empty_state.dart';
import 'gradient_button.dart';

/// Reusable error state widget following the EmptyState pattern
/// but with a Retry GradientButton action.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    this.title = 'Something went wrong',
    this.message,
    this.icon = Icons.error_outline_rounded,
    this.retryLabel = 'Try again',
    this.onRetry,
    this.compact = false,
    this.iconColor,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String retryLabel;
  final VoidCallback? onRetry;
  final bool compact;
  final Color? iconColor;

  /// Factory for network-specific errors.
  factory ErrorView.network({
    Key? key,
    VoidCallback? onRetry,
    bool compact = false,
  }) {
    return ErrorView(
      key: key,
      title: 'No connection',
      message: 'Check your internet and try again.',
      icon: Icons.wifi_off_rounded,
      onRetry: onRetry,
      compact: compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = iconColor ?? theme.colorScheme.error;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: compact ? 16 : 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon circle — mirrors EmptyState pattern
          Container(
            width: compact ? 56 : 72,
            height: compact ? 56 : 72,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: compact ? 28 : 36),
          ),
          SizedBox(height: compact ? 12 : 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 20),
            GradientButton(
              label: retryLabel,
              onPressed: onRetry,
              icon: Icons.refresh_rounded,
              gradient: AppGradients.primary,
              height: 48,
              borderRadius: 14,
              expand: false,
            ),
          ],
        ],
      ),
    );
  }
}
