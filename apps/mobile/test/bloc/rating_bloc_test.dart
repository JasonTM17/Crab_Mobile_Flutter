import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crab_mobile/features/rating/presentation/bloc/rating_bloc.dart';
import 'package:crab_mobile/features/rating/presentation/bloc/rating_event.dart';
import 'package:crab_mobile/features/rating/presentation/bloc/rating_state.dart';

import '../helpers/mocks.dart';
import '../helpers/fixtures.dart';

void main() {
  late MockRatingRepository mockRepo;

  setUp(() {
    mockRepo = MockRatingRepository();
  });

  group('RatingBloc', () {
    test('initial state is RatingInitial', () {
      final bloc = RatingBloc(mockRepo);
      expect(bloc.state, isA<RatingInitial>());
      bloc.close();
    });

    group('SubmitRating', () {
      blocTest<RatingBloc, RatingState>(
        'emits [RatingLoading, RatingSubmitted] on success',
        build: () {
          when(() => mockRepo.submitRating(
                targetType: 'ride',
                targetId: 'ride-uuid-001',
                score: 5,
                comment: 'Great',
                tags: any(named: 'tags'),
                rideId: any(named: 'rideId'),
                orderId: any(named: 'orderId'),
              )).thenAnswer((_) async {});
          return RatingBloc(mockRepo);
        },
        act: (bloc) => bloc.add(const SubmitRating(
          targetType: 'ride',
          targetId: 'ride-uuid-001',
          score: 5,
          comment: 'Great',
        )),
        expect: () => [
          isA<RatingLoading>(),
          isA<RatingSubmitted>(),
        ],
      );

      blocTest<RatingBloc, RatingState>(
        'emits [RatingLoading, RatingError] on failure',
        build: () {
          when(() => mockRepo.submitRating(
                targetType: any(named: 'targetType'),
                targetId: any(named: 'targetId'),
                score: any(named: 'score'),
                comment: any(named: 'comment'),
                tags: any(named: 'tags'),
                rideId: any(named: 'rideId'),
                orderId: any(named: 'orderId'),
              )).thenThrow(Exception('Error'));
          return RatingBloc(mockRepo);
        },
        act: (bloc) => bloc.add(const SubmitRating(
          targetType: 'ride',
          targetId: 'ride-001',
          score: 4,
        )),
        expect: () => [
          isA<RatingLoading>(),
          isA<RatingError>(),
        ],
      );
    });

    group('LoadReviews', () {
      blocTest<RatingBloc, RatingState>(
        'emits [RatingLoading, ReviewsLoaded] on success',
        build: () {
          when(() => mockRepo.getReviews('ride', 'ride-001'))
              .thenAnswer((_) async => [tRating]);
          when(() => mockRepo.getStats('ride', 'ride-001'))
              .thenAnswer((_) async => tRatingStats);
          return RatingBloc(mockRepo);
        },
        act: (bloc) => bloc.add(const LoadReviews(
          targetType: 'ride',
          targetId: 'ride-001',
        )),
        expect: () => [
          isA<RatingLoading>(),
          isA<ReviewsLoaded>().having((s) => s.reviews.length, 'count', 1),
        ],
      );
    });

    group('LoadRatingStats', () {
      blocTest<RatingBloc, RatingState>(
        'emits rating stats on success',
        build: () {
          when(() => mockRepo.getStats('ride', 'driver-001'))
              .thenAnswer((_) async => tRatingStats);
          return RatingBloc(mockRepo);
        },
        seed: () => const ReviewsLoaded(reviews: [], stats: null),
        act: (bloc) => bloc.add(const LoadRatingStats(
          targetType: 'ride',
          targetId: 'driver-001',
        )),
        expect: () => [
          isA<ReviewsLoaded>().having((s) => s.stats?.average, 'avg', 4.7),
        ],
      );
    });
  });
}
