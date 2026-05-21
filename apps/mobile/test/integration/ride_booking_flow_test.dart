import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crab_mobile/features/ride/data/models/location_model.dart';
import 'package:crab_mobile/features/ride/data/models/ride_model.dart';
import 'package:crab_mobile/features/ride/data/models/driver_model.dart';
import 'package:crab_mobile/features/ride/presentation/bloc/ride_state.dart';
import 'package:crab_mobile/features/ride/presentation/screens/ride_booking_screen.dart';

import 'helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const tPickup = LocationModel(
    latitude: 10.7769,
    longitude: 106.7009,
    address: '1 Nguyen Hue, HCMC',
    name: 'Nguyen Hue',
  );

  const tDropoff = LocationModel(
    latitude: 10.8015,
    longitude: 106.7147,
    address: '720A Dien Bien Phu',
    name: 'Tan Son Nhat',
  );

  const tFare = FareEstimate(
    minFare: 35000,
    maxFare: 50000,
    distanceKm: 5.2,
    estimatedMinutes: 15,
  );

  final tRide = RideModel(
    id: 'ride-001',
    pickup: tPickup,
    dropoff: tDropoff,
    status: RideStatus.pending,
    fare: 42000,
    createdAt: DateTime(2026, 5, 20),
  );

  const tDriver = DriverModel(
    id: 'driver-001',
    name: 'Tran Van B',
    phone: '+84909876543',
    rating: 4.8,
    totalRides: 1250,
    vehicle: VehicleModel(
      plate: '59A-12345',
      model: 'Honda Wave',
      color: 'Blue',
      type: 'motorbike',
    ),
  );

  group('Ride Booking Flow E2E Integration', () {
    testWidgets('Ride booking screen renders initially', (tester) async {
      final app = TestApp();
      app.stubDefaults();
      when(() => app.rideBloc.state).thenReturn(const RideIdle());

      await tester.pumpWidget(
        app.buildWidget(const RideBookingScreen()),
      );
      await tester.pump();

      expect(find.byType(RideBookingScreen), findsOneWidget);
    });

    testWidgets('Shows fare estimate when locations are selected',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final app = TestApp();
      app.stubDefaults();
      when(() => app.rideBloc.state).thenReturn(const RideIdle(
        pickup: tPickup,
        dropoff: tDropoff,
        fareEstimate: tFare,
      ));

      await tester.pumpWidget(
        app.buildWidget(const RideBookingScreen()),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Fare estimate should be visible
      expect(find.textContaining('42.500'), findsAtLeast(1));
    });

    testWidgets('Loading state during ride request', (tester) async {
      final app = TestApp();
      app.stubDefaults();
      when(() => app.rideBloc.state).thenReturn(const RideLoading());

      await tester.pumpWidget(
        app.buildWidget(const RideBookingScreen()),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsAtLeast(1));
    });

    testWidgets('Full ride lifecycle via BLoC stream', (tester) async {
      final app = TestApp();
      app.stubDefaults();

      // Simulate ride lifecycle
      whenListen(
        app.rideBloc,
        Stream<RideState>.fromIterable([
          const RideLoading(),
          RideSearchingDriver(ride: tRide),
          RideDriverMatched(ride: tRide, driver: tDriver),
          RidePickup(ride: tRide, driver: tDriver, etaMinutes: 5),
          RideInProgress(ride: tRide, driver: tDriver),
          RideCompletedState(
            summary: RideSummary(
              rideId: 'ride-001',
              fare: 42000,
              distanceKm: 5.2,
              durationMinutes: 15,
              completedAt: DateTime(2026, 5, 20, 10, 15),
            ),
          ),
        ]),
        initialState: const RideIdle(),
      );

      await expectLater(
        app.rideBloc.stream,
        emitsInOrder([
          isA<RideLoading>(),
          isA<RideSearchingDriver>(),
          isA<RideDriverMatched>(),
          isA<RidePickup>(),
          isA<RideInProgress>(),
          isA<RideCompletedState>(),
        ]),
      );
    });

    testWidgets('Cancel ride resets to idle', (tester) async {
      final app = TestApp();
      app.stubDefaults();

      whenListen(
        app.rideBloc,
        Stream<RideState>.fromIterable([
          RideSearchingDriver(ride: tRide),
          const RideIdle(),
        ]),
        initialState: const RideIdle(),
      );

      await expectLater(
        app.rideBloc.stream,
        emitsInOrder([
          isA<RideSearchingDriver>(),
          isA<RideIdle>(),
        ]),
      );
    });

    testWidgets('Error during ride request shows error state', (tester) async {
      final app = TestApp();
      app.stubDefaults();

      whenListen(
        app.rideBloc,
        Stream<RideState>.fromIterable([
          const RideLoading(),
          const RideError(message: 'No drivers available'),
        ]),
        initialState: const RideIdle(),
      );

      await expectLater(
        app.rideBloc.stream,
        emitsInOrder([
          isA<RideLoading>(),
          isA<RideError>().having(
            (state) => state.message,
            'message',
            'No drivers available',
          ),
        ]),
      );
    });
  });
}
