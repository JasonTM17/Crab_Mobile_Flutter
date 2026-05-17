import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/payment_models.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';
import '../widgets/transaction_tile.dart';
import 'top_up_screen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        elevation: 0,
      ),
      body: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is TopUpSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Top up successful!')),
            );
            context.read<PaymentBloc>().add(const LoadWallet());
          }
        },
        builder: (context, state) {
          if (state is PaymentLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PaymentError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<PaymentBloc>().add(const LoadWallet()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is WalletLoaded) {
            return _buildWalletContent(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildWalletContent(BuildContext context, WalletLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<PaymentBloc>().add(const LoadWallet());
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildBalanceCard(context, state.wallet),
          const SizedBox(height: 24),
          _buildQuickActions(context),
          const SizedBox(height: 24),
          const Text(
            'Recent Transactions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (state.transactions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text('No transactions yet',
                    style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            ...state.transactions.map(
              (tx) => TransactionTile(transaction: tx),
            ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, WalletModel wallet) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Balance',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '${_formatCurrency(wallet.balance)} ${wallet.currency}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.account_balance_wallet,
                  color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text(
                'Crab Wallet',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionButton(
          icon: Icons.add_circle_outline,
          label: 'Top Up',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TopUpScreen()),
          ),
        ),
        _ActionButton(
          icon: Icons.send_outlined,
          label: 'Transfer',
          onTap: () {},
        ),
        _ActionButton(
          icon: Icons.history,
          label: 'History',
          onTap: () {},
        ),
        _ActionButton(
          icon: Icons.local_offer_outlined,
          label: 'Promos',
          onTap: () {},
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)},000';
    }
    return amount.toStringAsFixed(0);
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
