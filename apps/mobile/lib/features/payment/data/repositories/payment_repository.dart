import 'package:injectable/injectable.dart';

import '../../../../core/network/dio_client.dart';
import '../models/payment_models.dart';

@injectable
class PaymentRepository {
  final DioClient _dioClient;

  PaymentRepository(this._dioClient);

  Future<WalletModel> getWallet() async {
    final response = await _dioClient.dio.get('/payment/wallet');
    return WalletModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<List<TransactionModel>> getTransactions({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dioClient.dio.get(
      '/payment/transactions',
      queryParameters: {'page': page, 'limit': limit},
    );
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<WalletModel> topUp({
    required double amount,
    required String method,
  }) async {
    final response = await _dioClient.dio.post(
      '/payment/wallet/topup',
      data: {'amount': amount, 'method': method},
    );
    return WalletModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<List<PromoModel>> getAvailablePromos() async {
    final response = await _dioClient.dio.get('/payment/promos');
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => PromoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PromoModel> applyPromo(String code) async {
    final response = await _dioClient.dio.post(
      '/payment/promos/apply',
      data: {'code': code},
    );
    return PromoModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
