import '../../data/models/payment_models.dart';

abstract class PaymentState {
  const PaymentState();
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

class WalletLoaded extends PaymentState {
  final WalletModel wallet;
  final List<TransactionModel> transactions;
  const WalletLoaded({required this.wallet, this.transactions = const []});

  WalletLoaded copyWith({
    WalletModel? wallet,
    List<TransactionModel>? transactions,
  }) {
    return WalletLoaded(
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
    );
  }
}

class TopUpSuccess extends PaymentState {
  final WalletModel wallet;
  const TopUpSuccess({required this.wallet});
}

class PromosLoaded extends PaymentState {
  final List<PromoModel> promos;
  const PromosLoaded({required this.promos});
}

class PromoApplied extends PaymentState {
  final PromoModel promo;
  const PromoApplied({required this.promo});
}

class PaymentError extends PaymentState {
  final String message;
  const PaymentError({required this.message});
}
