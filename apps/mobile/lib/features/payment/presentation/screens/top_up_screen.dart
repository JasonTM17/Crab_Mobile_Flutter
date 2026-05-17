import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  final _amounts = [50000.0, 100000.0, 200000.0, 500000.0, 1000000.0, 2000000.0];

  final _methods = [
    {'id': 'bank_transfer', 'name': 'Bank Transfer', 'icon': Icons.account_balance},
    {'id': 'momo', 'name': 'MoMo', 'icon': Icons.phone_android},
    {'id': 'zalopay', 'name': 'ZaloPay', 'icon': Icons.payment},
    {'id': 'vnpay', 'name': 'VNPay', 'icon': Icons.credit_card},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Top Up')),
      body: BlocListener<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is TopUpSuccess) {
            Navigator.of(context).pop();
          }
          if (state is PaymentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Select Amount',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _amounts.map((amount) {
                final isSelected = _selectedAmount == amount;
                return ChoiceChip(
                  label: Text('${(amount / 1000).toInt()}K'),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedAmount = selected ? amount : null);
                  },
                  selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...(_methods).map((method) {
              final isSelected = _selectedMethod == method['id'];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: ListTile(
                  leading: Icon(method['icon'] as IconData),
                  title: Text(method['name'] as String),
                  trailing: isSelected
                      ? Icon(Icons.check_circle,
                          color: Theme.of(context).primaryColor)
                      : null,
                  onTap: () {
                    setState(() => _selectedMethod = method['id'] as String);
                  },
                ),
              );
            }),
            const SizedBox(height: 32),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _selectedAmount != null
                    ? () {
                        context.read<PaymentBloc>().add(
                              TopUpWallet(
                                amount: _selectedAmount!,
                                method: _selectedMethod,
                              ),
                            );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _selectedAmount != null
                      ? 'Top Up ${(_selectedAmount! / 1000).toInt()}K VND'
                      : 'Select an amount',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
