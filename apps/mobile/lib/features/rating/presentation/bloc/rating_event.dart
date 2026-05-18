abstract class RatingEvent {
  const RatingEvent();
}

class SubmitRating extends RatingEvent {
  final String targetType;
  final String targetId;
  final double score;
  final String? comment;
  final List<String>? tags;
  final String? rideId;
  final String? orderId;
  const SubmitRating({
    required this.targetType,
    required this.targetId,
    required this.score,
    this.comment,
    this.tags,
    this.rideId,
    this.orderId,
  });
}

class LoadReviews extends RatingEvent {
  final String targetType;
  final String targetId;
  const LoadReviews({required this.targetType, required this.targetId});
}

class LoadRatingStats extends RatingEvent {
  final String targetType;
  final String targetId;
  const LoadRatingStats({required this.targetType, required this.targetId});
}
