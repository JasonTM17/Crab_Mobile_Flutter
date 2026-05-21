import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';

class PromosScreen extends StatefulWidget {
  const PromosScreen({super.key});

  @override
  State<PromosScreen> createState() => _PromosScreenState();
}

class _PromosScreenState extends State<PromosScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PaymentBloc>().add(const LoadPromos());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Promotions')),
      body: BlocBuilder<PaymentBloc, PaymentState>(
        builder: (context, state) {
          if (state is PaymentLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PaymentError) {
            return Center(child: Text(state.message));
          }
          final promos = state is PromosLoaded ? state.promos : const [];
          if (promos.isEmpty) {
            return const Center(child: Text('No active promos right now'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: promos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final promo = promos[index];
              return ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                tileColor: Theme.of(context).colorScheme.surface,
                leading: const Icon(Icons.local_offer_rounded),
                title: Text(promo.code),
                subtitle: Text(promo.description),
                trailing: Text(
                  promo.displayDiscount,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
