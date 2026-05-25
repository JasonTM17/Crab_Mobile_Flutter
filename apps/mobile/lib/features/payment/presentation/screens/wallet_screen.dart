import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/info_chip.dart';
import '../../data/models/payment_models.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';
import '../widgets/transaction_tile.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<PaymentBloc>().state;
      if (state is! WalletLoaded && state is! PaymentLoading) {
        context.read<PaymentBloc>().add(const LoadWallet());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        scrolledUnderElevation: 0,
        title: const Text(
          'Wallet',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
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
            return _WalletBody(state: state);
          }
          return _WalletBootstrap(
            onRetry: () => context.read<PaymentBloc>().add(const LoadWallet()),
          );
        },
      ),
    );
  }
}

class _WalletBootstrap extends StatelessWidget {
  const _WalletBootstrap({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppShadows.coloredGlow(AppColors.primary),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Loading your Crab Wallet',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your balance, top ups, and payment history will appear here.',
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: AppColors.textSecondaryLight, height: 1.4),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Load wallet'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletBody extends StatelessWidget {
  const _WalletBody({required this.state});

  final WalletLoaded state;

  @override
  Widget build(BuildContext context) {
    final groups = _groupTransactionsByDate(state.transactions);
    final credits = state.transactions
        .where((tx) => tx.isCredit)
        .fold<double>(0, (sum, tx) => sum + tx.amount.abs());
    final debits = state.transactions
        .where((tx) => !tx.isCredit)
        .fold<double>(0, (sum, tx) => sum + tx.amount.abs());

    return RefreshIndicator(
      onRefresh: () async =>
          context.read<PaymentBloc>().add(const LoadWallet()),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _BalanceCard(
                  wallet: state.wallet,
                  transactionCount: state.transactions.length),
              const SizedBox(height: 14),
              _WalletInsights(
                incomingTotal: credits,
                spendingTotal: debits,
                transactionCount: state.transactions.length,
              ),
              const SizedBox(height: 24),
              const _SectionHeader(
                title: 'Quick actions',
                subtitle: 'Top up, transfer, and review recent activity.',
              ),
              const SizedBox(height: 12),
              const _ActionPills(),
              const SizedBox(height: 24),
              _SectionHeader(
                title: 'Transactions',
                subtitle: state.transactions.isEmpty
                    ? 'Your latest wallet activity will show up here.'
                    : '${state.transactions.length} recent records across rides, food, and top ups.',
              ),
              const SizedBox(height: 12),
              if (state.transactions.isEmpty)
                const _EmptyTransactions()
              else
                ...groups.entries.map(
                  (group) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child:
                        _TransactionGroup(label: group.key, items: group.value),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, List<TransactionModel>> _groupTransactionsByDate(
    List<TransactionModel> txs,
  ) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    bool sameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    final groups = <String, List<TransactionModel>>{
      'TODAY': [],
      'YESTERDAY': [],
      'EARLIER': [],
    };
    for (final tx in txs) {
      if (sameDay(tx.createdAt, today)) {
        groups['TODAY']!.add(tx);
      } else if (sameDay(tx.createdAt, yesterday)) {
        groups['YESTERDAY']!.add(tx);
      } else {
        groups['EARLIER']!.add(tx);
      }
    }
    groups.removeWhere((_, value) => value.isEmpty);
    return groups;
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.wallet, required this.transactionCount});

  final WalletModel wallet;
  final int transactionCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        gradient: AppGradients.walletHero,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.coloredGlow(AppColors.primary, opacity: 0.30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _GlassPill(icon: Icons.shield_rounded, label: 'Protected'),
              const Spacer(),
              _GlassPill(
                icon: Icons.sync_rounded,
                label: _formatTime(wallet.updatedAt),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Crab Wallet',
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Available balance',
            style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            '${_formatAmount(wallet.balance)} ${wallet.currency}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Row(
              children: [
                Expanded(
                    child: _MetaItem(
                        label: 'Wallet ID', value: _maskWalletId(wallet.id))),
                Expanded(
                    child: _MetaItem(
                        label: 'Updated', value: _formatDay(wallet.updatedAt))),
                Expanded(
                    child: _MetaItem(
                        label: 'Records', value: '$transactionCount')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletInsights extends StatelessWidget {
  const _WalletInsights({
    required this.incomingTotal,
    required this.spendingTotal,
    required this.transactionCount,
  });

  final double incomingTotal;
  final double spendingTotal;
  final int transactionCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InsightCard(
            icon: Icons.arrow_downward_rounded,
            label: 'Incoming',
            value: _formatCompact(incomingTotal),
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _InsightCard(
            icon: Icons.arrow_upward_rounded,
            label: 'Spent',
            value: _formatCompact(spendingTotal),
            color: AppColors.accent,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _InsightCard(
            icon: Icons.receipt_long_rounded,
            label: 'Activity',
            value: '$transactionCount',
            color: AppColors.info,
          ),
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.7)),
        boxShadow: AppShadows.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondaryLight)),
        ],
      ),
    );
  }
}

class _ActionPills extends StatelessWidget {
  const _ActionPills();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _ActionCard(
                icon: Icons.add_rounded,
                label: 'Top up',
                onTap: () => context.push('/wallet/topup'))),
        const SizedBox(width: 10),
        Expanded(
            child: _ActionCard(
                icon: Icons.send_rounded,
                label: 'Transfer',
                onTap: () => context.push('/wallet/transfer'))),
        const SizedBox(width: 10),
        Expanded(
            child: _ActionCard(
                icon: Icons.local_offer_rounded,
                label: 'Promos',
                onTap: () => context.push('/promos'))),
        const SizedBox(width: 10),
        Expanded(
            child: _ActionCard(
                icon: Icons.history_rounded,
                label: 'History',
                onTap: () => context.push('/wallet/transactions'))),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard(
      {required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: AppColors.borderLight.withValues(alpha: 0.65)),
            boxShadow: AppShadows.shadowSoft,
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(height: 10),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionGroup extends StatelessWidget {
  const _TransactionGroup({required this.label, required this.items});

  final String label;
  final List<TransactionModel> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondaryLight,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: AppColors.borderLight.withValues(alpha: 0.7)),
            boxShadow: AppShadows.shadowSoft,
          ),
          child: Column(
            children: [
              for (int index = 0; index < items.length; index++) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: TransactionTile(transaction: items[index]),
                ),
                if (index != items.length - 1)
                  const Divider(
                      height: 1,
                      indent: 14,
                      endIndent: 14,
                      color: AppColors.borderLight),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.7)),
        boxShadow: AppShadows.shadowSoft,
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_rounded,
                color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 14),
          const Text('No transactions yet',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text(
            'Top up your wallet or pay for your first ride to start building history.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondaryLight,
                height: 1.45),
          ),
          const SizedBox(height: 14),
          const InfoChip(
            label: 'Ready for top up',
            icon: Icons.flash_on_rounded,
            variant: InfoChipVariant.brand,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimaryLight)),
        const SizedBox(height: 4),
        Text(subtitle,
            style: const TextStyle(
                fontSize: 12,
                height: 1.45,
                color: AppColors.textSecondaryLight)),
      ],
    );
  }
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 11,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}

String _formatAmount(double value) {
  final digits = value.abs().round().toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) buffer.write('.');
    buffer.write(digits[index]);
  }
  return buffer.toString();
}

String _formatCompact(double value) {
  if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K';
  return value.toStringAsFixed(0);
}

String _formatTime(DateTime value) =>
    '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

String _formatDay(DateTime value) => '${value.day}/${value.month}';

String _maskWalletId(String id) {
  if (id.length <= 4) return id;
  return '•••• ${id.substring(id.length - 4)}';
}
