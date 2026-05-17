import '../../data/models/rating_model.dart';

abstract class RatingState {
  const RatingState();
}

class RatingInitial extends RatingState {
  const RatingInitial();
}

class RatingLoading extends RatingState {
  const RatingLoading();
}

class RatingSubmitted extends RatingState {
  const RatingSubmitted();
}

class ReviewsLoaded extends RatingState {
  final List<RatingModel> reviews;
  final RatingStatsModel? stats;
  const ReviewsLoaded({required this.reviews, this.stats});
}

class RatingError extends RatingState {
  final String message;
  const RatingError({required this.message});
}
