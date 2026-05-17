import '../../data/models/payment_models.dart';

abstract class PaymentEvent {
  const PaymentEvent();
}

class LoadWallet extends PaymentEvent {
  const LoadWallet();
}

class LoadTransactions extends PaymentEvent {
  final int page;
  const LoadTransactions({this.page = 1});
}

class TopUpWallet extends PaymentEvent {
  final double amount;
  final String method;
  const TopUpWallet({required this.amount, required this.method});
}

class LoadPromos extends PaymentEvent {
  const LoadPromos();
}

class ApplyPromoCode extends PaymentEvent {
  final String code;
  const ApplyPromoCode({required this.code});
}
