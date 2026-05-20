import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/repositories/payment_repository.dart';
import '../../../../shared/utils/error_message.dart';
import 'payment_event.dart';
import 'payment_state.dart';

@injectable
class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository _paymentRepository;

  PaymentBloc(this._paymentRepository) : super(const PaymentInitial()) {
    on<LoadWallet>(_onLoadWallet);
    on<LoadTransactions>(_onLoadTransactions);
    on<TopUpWallet>(_onTopUpWallet);
    on<LoadPromos>(_onLoadPromos);
    on<ApplyPromoCode>(_onApplyPromoCode);
  }

  Future<void> _onLoadWallet(
    LoadWallet event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    try {
      final wallet = await _paymentRepository.getWallet();
      final transactions = await _paymentRepository.getTransactions();
      emit(WalletLoaded(wallet: wallet, transactions: transactions));
    } catch (e) {
      emit(PaymentError(message: mapErrorToMessage(e)));
    }
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      final transactions = await _paymentRepository.getTransactions(
        page: event.page,
      );
      final currentState = state;
      if (currentState is WalletLoaded) {
        emit(currentState.copyWith(transactions: transactions));
      }
    } catch (e) {
      emit(PaymentError(message: mapErrorToMessage(e)));
    }
  }

  Future<void> _onTopUpWallet(
    TopUpWallet event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    try {
      final wallet = await _paymentRepository.topUp(
        amount: event.amount,
        method: event.method,
      );
      emit(TopUpSuccess(wallet: wallet));
    } catch (e) {
      emit(PaymentError(message: mapErrorToMessage(e)));
    }
  }

  Future<void> _onLoadPromos(
    LoadPromos event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    try {
      final promos = await _paymentRepository.getAvailablePromos();
      emit(PromosLoaded(promos: promos));
    } catch (e) {
      emit(PaymentError(message: mapErrorToMessage(e)));
    }
  }

  Future<void> _onApplyPromoCode(
    ApplyPromoCode event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    try {
      final promo = await _paymentRepository.applyPromo(event.code);
      emit(PromoApplied(promo: promo));
    } catch (e) {
      emit(PaymentError(message: mapErrorToMessage(e)));
    }
  }
}
