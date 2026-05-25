import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crab_mobile/features/ride/presentation/bloc/ride_bloc.dart';
import 'package:crab_mobile/features/ride/presentation/bloc/ride_event.dart';
import 'package:crab_mobile/features/ride/presentation/bloc/ride_state.dart';

import '../helpers/mocks.dart';
import '../helpers/fixtures.dart';

void main() {
  late MockRideRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(tPickupLocation);
    registerFallbackValue(tDropoffLocation);
  });

  setUp(() {
    mockRepo = MockRideRepository();
  });

  group('RideBloc', () {
    test('initial state is RideIdle', () {
      final bloc = RideBloc(mockRepo);
      expect(bloc.state, const RideIdle());
      bloc.close();
    });

    // ═════════════════════════════════════════════════════
    // Location Selection
    // ═════════════════════════════════════════════════════
    group('PickupLocationSelected', () {
      blocTest<RideBloc, RideState>(
        'emits RideIdle with pickup location',
        build: () => RideBloc(mockRepo),
        act: (bloc) => bloc.add(
          const PickupLocationSelected(location: tPickupLocation),
        ),
        expect: () => [
          const RideIdle(pickup: tPickupLocation),
        ],
      );
    });

    group('DropoffLocationSelected', () {
      blocTest<RideBloc, RideState>(
        'emits RideIdle with dropoff location',
        build: () => RideBloc(mockRepo),
        act: (bloc) => bloc.add(
          const DropoffLocationSelected(location: tDropoffLocation),
        ),
        expect: () => [
          const RideIdle(dropoff: tDropoffLocation),
        ],
      );
    });

    // ═════════════════════════════════════════════════════
    // EstimateFareRequested
    // ═════════════════════════════════════════════════════
    group('EstimateFareRequested', () {
      blocTest<RideBloc, RideState>(
        'emits RideIdle with fareEstimate on success',
        build: () {
          when(() => mockRepo.estimateFare(
                pickup: any(named: 'pickup'),
                dropoff: any(named: 'dropoff'),
              )).thenAnswer((_) async => tFareEstimate);
          return RideBloc(mockRepo);
        },
        act: (bloc) => bloc.add(const EstimateFareRequested(
          pickup: tPickupLocation,
          dropoff: tDropoffLocation,
        )),
        expect: () => [
          const RideIdle(
            pickup: tPickupLocation,
            dropoff: tDropoffLocation,
            fareEstimate: tFareEstimate,
          ),
        ],
      );

      blocTest<RideBloc, RideState>(
        'emits RideError on failure',
        build: () {
          when(() => mockRepo.estimateFare(
                pickup: any(named: 'pickup'),
                dropoff: any(named: 'dropoff'),
              )).thenThrow(Exception('Network error'));
          return RideBloc(mockRepo);
        },
        act: (bloc) => bloc.add(const EstimateFareRequested(
          pickup: tPickupLocation,
          dropoff: tDropoffLocation,
        )),
        expect: () => [
          isA<RideError>(),
        ],
      );
    });

    // ═════════════════════════════════════════════════════
    // RequestRide
    // ═════════════════════════════════════════════════════
    group('RequestRide', () {
      blocTest<RideBloc, RideState>(
        'emits [RideLoading, RideSearchingDriver] on success',
        build: () {
          when(() => mockRepo.createRide(
                pickup: any(named: 'pickup'),
                dropoff: any(named: 'dropoff'),
              )).thenAnswer((_) async => tRideModel);
          return RideBloc(mockRepo);
        },
        act: (bloc) => bloc.add(const RequestRide(
          pickup: tPickupLocation,
          dropoff: tDropoffLocation,
        )),
        expect: () => [
          const RideLoading(),
          RideSearchingDriver(ride: tRideModel),
        ],
      );

      blocTest<RideBloc, RideState>(
        'emits [RideLoading, RideError] on failure',
        build: () {
          when(() => mockRepo.createRide(
                pickup: any(named: 'pickup'),
                dropoff: any(named: 'dropoff'),
              )).thenThrow(Exception('Server error'));
          return RideBloc(mockRepo);
        },
        act: (bloc) => bloc.add(const RequestRide(
          pickup: tPickupLocation,
          dropoff: tDropoffLocation,
        )),
        expect: () => [
          const RideLoading(),
          isA<RideError>(),
        ],
      );
    });

    // ═════════════════════════════════════════════════════
    // CancelRide
    // ═════════════════════════════════════════════════════
    group('CancelRide', () {
      blocTest<RideBloc, RideState>(
        'emits RideIdle on success',
        build: () {
          when(() => mockRepo.cancelRide('ride-uuid-001'))
              .thenAnswer((_) async {});
          return RideBloc(mockRepo);
        },
        act: (bloc) => bloc.add(const CancelRide(rideId: 'ride-uuid-001')),
        expect: () => [const RideIdle()],
      );

      blocTest<RideBloc, RideState>(
        'emits RideError on failure',
        build: () {
          when(() => mockRepo.cancelRide('ride-uuid-001'))
              .thenThrow(Exception('Cannot cancel'));
          return RideBloc(mockRepo);
        },
        act: (bloc) => bloc.add(const CancelRide(rideId: 'ride-uuid-001')),
        expect: () => [isA<RideError>()],
      );
    });

    // ═════════════════════════════════════════════════════
    // DriverMatched
    // ═════════════════════════════════════════════════════
    group('DriverMatched', () {
      final driverJson = {
        'id': 'driver-uuid-001',
        'name': 'Tran Van B',
        'phone': '+84909876543',
        'rating': 4.8,
        'totalRides': 1250,
        'vehicle': {
          'plate': '59A-12345',
          'model': 'Honda Wave Alpha',
          'color': 'Blue',
          'type': 'motorbike',
        },
      };

      blocTest<RideBloc, RideState>(
        'emits RideDriverMatched when currently searching',
        build: () => RideBloc(mockRepo),
        seed: () => RideSearchingDriver(ride: tRideModel),
        act: (bloc) => bloc.add(DriverMatched(driverData: driverJson)),
        expect: () => [
          isA<RideDriverMatched>()
              .having((s) => s.ride, 'ride', tRideModel)
              .having((s) => s.driver.id, 'driver.id', 'driver-uuid-001'),
        ],
      );
    });

    // ═════════════════════════════════════════════════════
    // RideStatusChanged
    // ═════════════════════════════════════════════════════
    group('RideStatusChanged', () {
      blocTest<RideBloc, RideState>(
        'status=pickup transitions from DriverMatched to RidePickup',
        build: () => RideBloc(mockRepo),
        seed: () => RideDriverMatched(ride: tRideModel, driver: tDriverModel),
        act: (bloc) => bloc.add(const RideStatusChanged(
          status: 'pickup',
          extra: {'etaMinutes': 3},
        )),
        expect: () => [
          isA<RidePickup>().having((s) => s.etaMinutes, 'etaMinutes', 3),
        ],
      );

      blocTest<RideBloc, RideState>(
        'status=in_progress transitions from RidePickup to RideInProgress',
        build: () => RideBloc(mockRepo),
        seed: () => RidePickup(
          ride: tRideModel,
          driver: tDriverModel,
          etaMinutes: 3,
        ),
        act: (bloc) => bloc.add(const RideStatusChanged(status: 'in_progress')),
        expect: () => [
          isA<RideInProgress>().having((s) => s.ride, 'ride', tRideModel),
        ],
      );

      blocTest<RideBloc, RideState>(
        'status=cancelled resets to RideIdle',
        build: () => RideBloc(mockRepo),
        seed: () => RideSearchingDriver(ride: tRideModel),
        act: (bloc) => bloc.add(const RideStatusChanged(status: 'cancelled')),
        expect: () => [const RideIdle()],
      );
    });

    // ═════════════════════════════════════════════════════
    // LocationUpdate
    // ═════════════════════════════════════════════════════
    group('LocationUpdate', () {
      blocTest<RideBloc, RideState>(
        'updates driver location during RidePickup',
        build: () => RideBloc(mockRepo),
        seed: () => RidePickup(
          ride: tRideModel,
          driver: tDriverModel,
          etaMinutes: 3,
        ),
        act: (bloc) => bloc.add(
          const LocationUpdate(latitude: 10.78, longitude: 106.71),
        ),
        expect: () => [
          isA<RidePickup>().having(
            (s) => s.driverLocation?.latitude,
            'driverLocation.lat',
            10.78,
          ),
        ],
      );

      blocTest<RideBloc, RideState>(
        'updates driver location during RideInProgress',
        build: () => RideBloc(mockRepo),
        seed: () => RideInProgress(ride: tRideModel, driver: tDriverModel),
        act: (bloc) => bloc.add(
          const LocationUpdate(latitude: 10.80, longitude: 106.72),
        ),
        expect: () => [
          isA<RideInProgress>().having(
            (s) => s.driverLocation?.latitude,
            'driverLocation.lat',
            10.80,
          ),
        ],
      );
    });

    // ═════════════════════════════════════════════════════
    // RideCompleted
    // ═════════════════════════════════════════════════════
    group('RideCompleted', () {
      blocTest<RideBloc, RideState>(
        'emits RideCompletedState with summary',
        build: () => RideBloc(mockRepo),
        act: (bloc) => bloc.add(const RideCompleted(summaryData: {
          'rideId': 'ride-uuid-001',
          'fare': 42000,
          'currency': 'VND',
          'distanceKm': 5.2,
          'durationMinutes': 15,
          'completedAt': '2026-05-20T10:15:00.000',
        })),
        expect: () => [
          isA<RideCompletedState>()
              .having((s) => s.summary.rideId, 'rideId', 'ride-uuid-001')
              .having((s) => s.summary.fare, 'fare', 42000),
        ],
      );
    });
  });
}
