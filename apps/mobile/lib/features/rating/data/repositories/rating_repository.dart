import 'package:injectable/injectable.dart';

import '../../../../core/network/dio_client.dart';
import '../models/rating_model.dart';

@injectable
class RatingRepository {
  final DioClient _dioClient;

  RatingRepository(this._dioClient);

  Future<void> submitRating({
    required String targetType,
    required String targetId,
    required double score,
    String? comment,
    List<String>? tags,
    String? rideId,
    String? orderId,
  }) async {
    await _dioClient.dio.post('/reviews', data: {
      'targetType': targetType,
      'targetId': targetId,
      'score': score,
      if (comment != null) 'comment': comment,
      if (tags != null) 'tags': tags,
      if (rideId != null) 'rideId': rideId,
      if (orderId != null) 'orderId': orderId,
    });
  }

  Future<RatingStatsModel> getStats(String targetType, String targetId) async {
    final response = await _dioClient.dio.get(
      '/reviews/stats/$targetType/$targetId',
    );
    return RatingStatsModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  Future<List<RatingModel>> getReviews(
    String targetType,
    String targetId, {
    int page = 1,
  }) async {
    final response = await _dioClient.dio.get(
      '/reviews/$targetType/$targetId',
      queryParameters: {'page': page},
    );
    final list = response.data['data']['reviews'] as List<dynamic>;
    return list
        .map((e) => RatingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<RatingModel>> getMyReviews() async {
    final response = await _dioClient.dio.get('/reviews/user');
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => RatingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
