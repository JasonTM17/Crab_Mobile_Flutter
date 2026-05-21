import 'package:flutter/material.dart';

import '../../../../shared/widgets/gradient_button.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transfer')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Recipient phone',
              prefixIcon: Icon(Icons.phone_rounded),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixIcon: Icon(Icons.payments_rounded),
              suffixText: 'VND',
            ),
          ),
          const SizedBox(height: 24),
          GradientButton(
            label: 'Review Transfer',
            icon: Icons.arrow_forward_rounded,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transfer review is ready')),
              );
            },
          ),
        ],
      ),
    );
  }
}
