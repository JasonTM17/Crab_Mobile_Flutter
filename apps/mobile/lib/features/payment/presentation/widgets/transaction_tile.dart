import 'package:flutter/material.dart';

import '../../data/models/payment_models.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: transaction.isCredit
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getIcon(),
              color: transaction.isCredit ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ?? _getTitle(),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(transaction.createdAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            '${transaction.isCredit ? '+' : '-'}${_formatAmount(transaction.amount)}đ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: transaction.isCredit ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (transaction.type) {
      case 'topup':
        return Icons.add_circle_outline;
      case 'ride_payment':
        return Icons.directions_car;
      case 'food_payment':
        return Icons.restaurant;
      case 'refund':
        return Icons.replay;
      default:
        return Icons.swap_horiz;
    }
  }

  String _getTitle() {
    switch (transaction.type) {
      case 'topup':
        return 'Top Up';
      case 'ride_payment':
        return 'Ride Payment';
      case 'food_payment':
        return 'Food Order';
      case 'refund':
        return 'Refund';
      default:
        return 'Transaction';
    }
  }

  String _formatAmount(double amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)},000';
    }
    return amount.toStringAsFixed(0);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
