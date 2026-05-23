import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/info_chip.dart';
import '../../data/models/payment_models.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final amountColor = transaction.isCredit ? AppColors.success : AppColors.error;
    final title = transaction.description?.trim().isNotEmpty == true
        ? transaction.description!.trim()
        : _title;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: amountColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_icon, color: amountColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_typeLabel()} • ${_formatDate(transaction.createdAt)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${transaction.isCredit ? '+' : '-'}${_formatAmount(transaction.amount)}đ',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: amountColor),
              ),
              const SizedBox(height: 6),
              InfoChip(label: _statusLabel(), variant: _statusVariant(), dense: true),
            ],
          ),
        ],
      ),
    );
  }

  IconData get _icon {
    switch (transaction.type) {
      case 'topup':
        return Icons.add_circle_outline_rounded;
      case 'ride_payment':
        return Icons.directions_car_rounded;
      case 'food_payment':
        return Icons.restaurant_rounded;
      case 'refund':
        return Icons.replay_rounded;
      default:
        return Icons.swap_horiz_rounded;
    }
  }

  String get _title {
    switch (transaction.type) {
      case 'topup':
        return 'Top Up';
      case 'ride_payment':
        return 'Ride payment';
      case 'food_payment':
        return 'Food order';
      case 'refund':
        return 'Refund';
      default:
        return 'Transaction';
    }
  }

  String _typeLabel() {
    switch (transaction.type) {
      case 'topup':
        return 'Wallet top up';
      case 'ride_payment':
        return 'Ride';
      case 'food_payment':
        return 'Food';
      case 'refund':
        return 'Refund';
      default:
        return 'Payment';
    }
  }

  String _statusLabel() {
    switch (transaction.status.toLowerCase()) {
      case 'success':
      case 'completed':
        return 'Completed';
      case 'pending':
        return 'Pending';
      case 'failed':
      case 'cancelled':
        return 'Issue';
      default:
        return transaction.status;
    }
  }

  InfoChipVariant _statusVariant() {
    switch (transaction.status.toLowerCase()) {
      case 'success':
      case 'completed':
        return InfoChipVariant.success;
      case 'pending':
        return InfoChipVariant.warning;
      case 'failed':
      case 'cancelled':
        return InfoChipVariant.error;
      default:
        return transaction.isCredit ? InfoChipVariant.brand : InfoChipVariant.defaults;
    }
  }

  String _formatAmount(double amount) {
    final digits = amount.abs().round().toString();
    final buffer = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) buffer.write('.');
      buffer.write(digits[index]);
    }
    return buffer.toString();
  }

  String _formatDate(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day}/${date.month}/${date.year} • $hour:$minute';
  }
}
