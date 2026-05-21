import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  double? _selectedAmount;
  String _selectedMethod = 'bank_transfer';

  static const _amounts = <double>[
    50000,
    100000,
    200000,
    500000,
    1000000,
    2000000,
  ];

  static const _methods = <_Method>[
    _Method('bank_transfer', 'Bank Transfer', 'Direct from your bank',
        Icons.account_balance_rounded),
    _Method(
        'momo', 'MoMo', 'Most popular in Vietnam', Icons.phone_android_rounded),
    _Method('zalopay', 'ZaloPay', 'Instant top-up via ZaloPay',
        Icons.payment_rounded),
    _Method('vnpay', 'VNPay', 'Card / QR via VNPay', Icons.credit_card_rounded),
  ];

  String _formatVnd(double v) {
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Top Up',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is TopUpSuccess) {
            Navigator.of(context).pop();
          }
          if (state is PaymentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: cs.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final loading = state is PaymentLoading;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _PreviewCard(amount: _selectedAmount, formatter: _formatVnd),
              const SizedBox(height: 22),
              const _SectionLabel(text: 'Choose amount'),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.0,
                children: _amounts.map((a) {
                  final selected = _selectedAmount == a;
                  return _AmountTile(
                    label: '${(a / 1000).toInt()}K',
                    selected: selected,
                    onTap: () =>
                        setState(() => _selectedAmount = selected ? null : a),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const _SectionLabel(text: 'Payment method'),
              const SizedBox(height: 12),
              ..._methods.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _MethodTile(
                      method: m,
                      selected: _selectedMethod == m.id,
                      onTap: () => setState(() => _selectedMethod = m.id),
                    ),
                  )),
              const SizedBox(height: 28),
              GradientButton(
                label: _selectedAmount != null
                    ? 'Top up ${_formatVnd(_selectedAmount!)} VND'
                    : 'Select an amount',
                icon: Icons.flash_on_rounded,
                onPressed: (_selectedAmount != null && !loading)
                    ? () => context.read<PaymentBloc>().add(
                          TopUpWallet(
                            amount: _selectedAmount!,
                            method: _selectedMethod,
                          ),
                        )
                    : null,
                loading: loading,
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Funds usually arrive within seconds.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Method {
  final String id;
  final String name;
  final String tagline;
  final IconData icon;
  const _Method(this.id, this.name, this.tagline, this.icon);
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.amount, required this.formatter});
  final double? amount;
  final String Function(double) formatter;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        gradient: AppGradients.walletHero,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B14F).withValues(alpha: 0.28),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You will top up',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.86),
              fontSize: 13,
              letterSpacing: 0.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedSwitcher(
            duration: AppMotion.fast,
            child: Text(
              amount == null ? '—' : '${formatter(amount!)} đ',
              key: ValueKey(amount),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No fee from Crab Wallet',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
      ),
    );
  }
}

class _AmountTile extends StatelessWidget {
  const _AmountTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        decoration: BoxDecoration(
          gradient: selected ? AppGradients.primary : null,
          color: selected
              ? null
              : cs.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? Colors.transparent : Colors.transparent,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.30),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : cs.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });
  final _Method method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? cs.primary
                  : cs.outlineVariant.withValues(alpha: 0.4),
              width: selected ? 1.6 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(method.icon, color: cs.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      method.tagline,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: AppMotion.fast,
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? cs.primary : cs.outlineVariant,
                    width: selected ? 7 : 1.6,
                  ),
                  color: cs.surface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
