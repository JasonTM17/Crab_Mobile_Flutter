import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crab_mobile/features/ride/driver/presentation/bloc/driver_bloc.dart';
import 'package:crab_mobile/features/ride/driver/presentation/bloc/driver_event.dart';
import 'package:crab_mobile/features/ride/driver/presentation/bloc/driver_state.dart';

import '../helpers/mocks.dart';
import '../helpers/fixtures.dart';

void main() {
  late MockDriverRepository mockRepo;

  setUp(() {
    mockRepo = MockDriverRepository();
  });

  group('DriverBloc', () {
    test('initial state is DriverOffline', () {
      final bloc = DriverBloc(mockRepo);
      expect(bloc.state, isA<DriverOffline>());
      bloc.close();
    });

    group('GoOnline', () {
      blocTest<DriverBloc, DriverState>(
        'emits DriverOnlineIdle on success',
        build: () {
          when(() => mockRepo.goOnline()).thenAnswer((_) async {});
          return DriverBloc(mockRepo);
        },
        act: (bloc) => bloc.add(const GoOnline()),
        expect: () => [isA<DriverOnlineIdle>()],
      );

      blocTest<DriverBloc, DriverState>(
        'emits DriverError on failure',
        build: () {
          when(() => mockRepo.goOnline()).thenThrow(Exception('Error'));
          return DriverBloc(mockRepo);
        },
        act: (bloc) => bloc.add(const GoOnline()),
        expect: () => [isA<DriverError>()],
      );
    });

    group('GoOffline', () {
      blocTest<DriverBloc, DriverState>(
        'emits DriverOffline on success',
        build: () {
          when(() => mockRepo.goOffline()).thenAnswer((_) async {});
          return DriverBloc(mockRepo);
        },
        seed: () => const DriverOnlineIdle(),
        act: (bloc) => bloc.add(const GoOffline()),
        expect: () => [isA<DriverOffline>()],
      );
    });

    group('RideRequestReceived', () {
      blocTest<DriverBloc, DriverState>(
        'emits DriverRideRequest with countdown',
        build: () => DriverBloc(mockRepo),
        seed: () => const DriverOnlineIdle(),
        act: (bloc) => bloc.add(const RideRequestReceived(rideRequestData: {
          'id': 'ride-001',
          'pickupAddress': '123 Le Loi',
          'dropoffAddress': '456 Pasteur',
          'pickupLat': 10.77,
          'pickupLng': 106.70,
          'dropoffLat': 10.80,
          'dropoffLng': 106.71,
          'estimatedFare': 42000,
          'distanceKm': 5.2,
          'currency': 'VND',
        })),
        expect: () => [isA<DriverRideRequest>()],
      );
    });

    group('AcceptRide', () {
      blocTest<DriverBloc, DriverState>(
        'emits DriverNavigatingToPickup on success',
        build: () {
          when(() => mockRepo.acceptRide('ride-001'))
              .thenAnswer((_) async => tRideModel);
          return DriverBloc(mockRepo);
        },
        act: (bloc) => bloc.add(const AcceptRide(rideId: 'ride-001')),
        expect: () => [isA<DriverNavigatingToPickup>()],
      );
    });

    group('RejectRide', () {
      blocTest<DriverBloc, DriverState>(
        'emits DriverOnlineIdle on reject',
        build: () {
          when(() => mockRepo.rejectRide('ride-001')).thenAnswer((_) async {});
          return DriverBloc(mockRepo);
        },
        act: (bloc) => bloc.add(const RejectRide(rideId: 'ride-001')),
        expect: () => [isA<DriverOnlineIdle>()],
      );
    });

    group('StartRide', () {
      blocTest<DriverBloc, DriverState>(
        'emits DriverInRide on start',
        build: () {
          when(() => mockRepo.startRide('ride-001'))
              .thenAnswer((_) async => tRideModel);
          return DriverBloc(mockRepo);
        },
        seed: () => DriverNavigatingToPickup(ride: tRideModel),
        act: (bloc) => bloc.add(const StartRide(rideId: 'ride-001')),
        expect: () => [isA<DriverInRide>()],
      );
    });

    group('CompleteRide', () {
      blocTest<DriverBloc, DriverState>(
        'emits DriverOnlineIdle on complete',
        build: () {
          when(() => mockRepo.completeRide('ride-001'))
              .thenAnswer((_) async => tRideModel);
          return DriverBloc(mockRepo);
        },
        seed: () => DriverInRide(ride: tRideModel),
        act: (bloc) => bloc.add(const CompleteRide(rideId: 'ride-001')),
        expect: () => [isA<DriverOnlineIdle>()],
      );
    });

    group('CountdownTick', () {
      blocTest<DriverBloc, DriverState>(
        'decrements countdown in DriverRideRequest',
        build: () => DriverBloc(mockRepo),
        seed: () => const DriverRideRequest(
          rideRequest: RideRequest(
            id: 'ride-001',
            pickupAddress: 'Pickup',
            dropoffAddress: 'Dropoff',
            pickupLat: 0.0,
            pickupLng: 0.0,
            dropoffLat: 0.0,
            dropoffLng: 0.0,
            estimatedFare: 100.0,
            distanceKm: 1.0,
          ),
          countdown: 15,
        ),
        act: (bloc) => bloc.add(const CountdownTick(remaining: 10)),
        expect: () => [
          isA<DriverRideRequest>().having((s) => s.countdown, 'countdown', 10),
        ],
      );
    });
  });
}
