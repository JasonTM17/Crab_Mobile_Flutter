import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';
import '../widgets/transaction_tile.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PaymentBloc>().add(const LoadWallet());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: BlocBuilder<PaymentBloc, PaymentState>(
        builder: (context, state) {
          if (state is PaymentLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PaymentError) {
            return _PaymentMessage(
              icon: Icons.error_outline,
              title: 'Could not load transactions',
              message: state.message,
              onRetry: () =>
                  context.read<PaymentBloc>().add(const LoadWallet()),
            );
          }
          final transactions =
              state is WalletLoaded ? state.transactions : const [];
          if (transactions.isEmpty) {
            return const _PaymentMessage(
              icon: Icons.receipt_long_outlined,
              title: 'No transactions yet',
              message: 'Wallet activity will appear here.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async =>
                context.read<PaymentBloc>().add(const LoadWallet()),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, index) =>
                  TransactionTile(transaction: transactions[index]),
            ),
          );
        },
      ),
    );
  }
}

class _PaymentMessage extends StatelessWidget {
  const _PaymentMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.onRetry,
  });
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}
