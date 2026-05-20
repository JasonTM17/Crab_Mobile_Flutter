import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/repositories/rating_repository.dart';
import '../../../../shared/utils/error_message.dart';
import 'rating_event.dart';
import 'rating_state.dart';

@injectable
class RatingBloc extends Bloc<RatingEvent, RatingState> {
  final RatingRepository _ratingRepository;

  RatingBloc(this._ratingRepository) : super(const RatingInitial()) {
    on<SubmitRating>(_onSubmitRating);
    on<LoadReviews>(_onLoadReviews);
    on<LoadRatingStats>(_onLoadRatingStats);
  }

  Future<void> _onSubmitRating(
    SubmitRating event,
    Emitter<RatingState> emit,
  ) async {
    emit(const RatingLoading());
    try {
      await _ratingRepository.submitRating(
        targetType: event.targetType,
        targetId: event.targetId,
        score: event.score,
        comment: event.comment,
        tags: event.tags,
        rideId: event.rideId,
        orderId: event.orderId,
      );
      emit(const RatingSubmitted());
    } catch (e) {
      emit(RatingError(message: mapErrorToMessage(e)));
    }
  }

  Future<void> _onLoadReviews(
    LoadReviews event,
    Emitter<RatingState> emit,
  ) async {
    emit(const RatingLoading());
    try {
      final reviews = await _ratingRepository.getReviews(
        event.targetType,
        event.targetId,
      );
      final stats = await _ratingRepository.getStats(
        event.targetType,
        event.targetId,
      );
      emit(ReviewsLoaded(reviews: reviews, stats: stats));
    } catch (e) {
      emit(RatingError(message: mapErrorToMessage(e)));
    }
  }

  Future<void> _onLoadRatingStats(
    LoadRatingStats event,
    Emitter<RatingState> emit,
  ) async {
    try {
      final stats = await _ratingRepository.getStats(
        event.targetType,
        event.targetId,
      );
      final currentState = state;
      if (currentState is ReviewsLoaded) {
        emit(ReviewsLoaded(reviews: currentState.reviews, stats: stats));
      }
    } catch (e) {
      emit(RatingError(message: mapErrorToMessage(e)));
    }
  }
}
