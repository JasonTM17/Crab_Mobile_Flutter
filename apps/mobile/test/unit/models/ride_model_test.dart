import 'package:flutter_test/flutter_test.dart';
import 'package:crab_mobile/features/ride/data/models/location_model.dart';
import 'package:crab_mobile/features/ride/data/models/ride_model.dart';
import 'package:crab_mobile/features/ride/data/models/driver_model.dart';

void main() {
  group('LocationModel', () {
    test('fromJson parses all fields', () {
      final json = {
        'latitude': 10.7769,
        'longitude': 106.7009,
        'address': '1 Nguyen Hue',
        'name': 'Walking Street',
      };
      final loc = LocationModel.fromJson(json);
      expect(loc.latitude, 10.7769);
      expect(loc.longitude, 106.7009);
      expect(loc.address, '1 Nguyen Hue');
      expect(loc.name, 'Walking Street');
    });

    test('fromJson handles null optionals', () {
      final json = {'latitude': 10.0, 'longitude': 106.0};
      final loc = LocationModel.fromJson(json);
      expect(loc.address, isNull);
      expect(loc.name, isNull);
    });

    test('toJson round-trip', () {
      const loc = LocationModel(
        latitude: 10.5,
        longitude: 106.5,
        address: 'Test',
        name: 'Test Place',
      );
      final json = loc.toJson();
      final loc2 = LocationModel.fromJson(json);
      expect(loc2.latitude, loc.latitude);
      expect(loc2.longitude, loc.longitude);
      expect(loc2.address, loc.address);
    });

    test('supports equality', () {
      const a = LocationModel(latitude: 10.0, longitude: 106.0);
      const b = LocationModel(latitude: 10.0, longitude: 106.0);
      expect(a, equals(b));
    });
  });

  group('FareEstimate', () {
    test('fromJson parses all fields', () {
      final json = {
        'minFare': 35000,
        'maxFare': 50000,
        'distanceKm': 5.2,
        'estimatedMinutes': 15,
        'currency': 'VND',
      };
      final fare = FareEstimate.fromJson(json);
      expect(fare.minFare, 35000);
      expect(fare.maxFare, 50000);
      expect(fare.distanceKm, 5.2);
      expect(fare.estimatedMinutes, 15);
      expect(fare.currency, 'VND');
    });

    test('toJson round-trip', () {
      const fare = FareEstimate(
        minFare: 20000,
        maxFare: 30000,
        distanceKm: 3.0,
        estimatedMinutes: 10,
        currency: 'VND',
      );
      final json = fare.toJson();
      final fare2 = FareEstimate.fromJson(json);
      expect(fare2.minFare, fare.minFare);
      expect(fare2.distanceKm, fare.distanceKm);
    });
  });

  group('RideModel', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': 'r1',
        'pickup': {'latitude': 10.7, 'longitude': 106.7},
        'dropoff': {'latitude': 10.8, 'longitude': 106.8},
        'status': 'pending',
        'fare': 42000,
        'currency': 'VND',
        'etaMinutes': 5,
        'createdAt': '2026-05-20T10:00:00.000',
      };
      final ride = RideModel.fromJson(json);
      expect(ride.id, 'r1');
      expect(ride.status, RideStatus.pending);
      expect(ride.fare, 42000);
      expect(ride.etaMinutes, 5);
    });

    test('RideStatus enum values', () {
      expect(RideStatus.values.length, 7);
      expect(RideStatus.pending.name, 'pending');
      expect(RideStatus.completed.name, 'completed');
      expect(RideStatus.cancelled.name, 'cancelled');
    });
  });

  group('RideSummary', () {
    test('fromJson parses correctly', () {
      final json = {
        'rideId': 'r1',
        'fare': 42000,
        'currency': 'VND',
        'distanceKm': 5.2,
        'durationMinutes': 15,
        'completedAt': '2026-05-20T10:15:00.000',
      };
      final summary = RideSummary.fromJson(json);
      expect(summary.rideId, 'r1');
      expect(summary.fare, 42000);
      expect(summary.distanceKm, 5.2);
      expect(summary.durationMinutes, 15);
    });
  });

  group('DriverModel', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': 'd1',
        'name': 'Driver A',
        'phone': '+84909',
        'rating': 4.8,
        'totalRides': 1250,
        'vehicle': {
          'plate': '59A-123',
          'model': 'Honda Wave',
          'color': 'Blue',
          'type': 'motorbike',
        },
      };
      final driver = DriverModel.fromJson(json);
      expect(driver.id, 'd1');
      expect(driver.name, 'Driver A');
      expect(driver.rating, 4.8);
      expect(driver.totalRides, 1250);
      expect(driver.vehicle.plate, '59A-123');
      expect(driver.vehicle.model, 'Honda Wave');
    });

    test('fromJson handles null optionals', () {
      final json = {
        'id': 'd2',
        'name': 'B',
        'phone': '+84',
        'rating': 4.0,
        'totalRides': 0,
        'vehicle': {
          'plate': 'X',
          'model': 'Y',
          'color': 'Z',
          'type': 'car',
        },
      };
      final driver = DriverModel.fromJson(json);
      expect(driver.avatar, isNull);
      expect(driver.currentLocation, isNull);
    });
  });

  group('VehicleModel', () {
    test('fromJson parses correctly', () {
      final json = {
        'plate': '59A-12345',
        'model': 'Toyota Vios',
        'color': 'White',
        'type': 'car',
      };
      final v = VehicleModel.fromJson(json);
      expect(v.plate, '59A-12345');
      expect(v.model, 'Toyota Vios');
      expect(v.color, 'White');
      expect(v.type, 'car');
    });

    test('toJson round-trip', () {
      const v = VehicleModel(
        plate: 'ABC',
        model: 'Test',
        color: 'Red',
        type: 'motorbike',
      );
      final json = v.toJson();
      final v2 = VehicleModel.fromJson(json);
      expect(v2.plate, v.plate);
      expect(v2.type, v.type);
    });
  });
}
