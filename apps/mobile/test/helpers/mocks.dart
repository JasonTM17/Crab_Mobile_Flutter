// ignore_for_file: subtype_of_sealed_class

import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crab_mobile/shared/services/auth_storage.dart';
import 'package:crab_mobile/core/network/dio_client.dart';
import 'package:crab_mobile/core/network/socket_client.dart';

import 'package:crab_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:crab_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:crab_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:crab_mobile/features/auth/presentation/bloc/auth_state.dart';

import 'package:crab_mobile/features/home/presentation/bloc/home_bloc.dart';
import 'package:crab_mobile/features/home/presentation/bloc/home_event.dart';
import 'package:crab_mobile/features/home/presentation/bloc/home_state.dart';

import 'package:crab_mobile/features/ride/data/repositories/ride_repository.dart';
import 'package:crab_mobile/features/ride/presentation/bloc/ride_bloc.dart';
import 'package:crab_mobile/features/ride/presentation/bloc/ride_event.dart';
import 'package:crab_mobile/features/ride/presentation/bloc/ride_state.dart';

import 'package:crab_mobile/features/ride/driver/data/repositories/driver_repository.dart';
import 'package:crab_mobile/features/ride/driver/presentation/bloc/driver_bloc.dart';
import 'package:crab_mobile/features/ride/driver/presentation/bloc/driver_event.dart';
import 'package:crab_mobile/features/ride/driver/presentation/bloc/driver_state.dart';

import 'package:crab_mobile/features/food/data/repositories/food_repository.dart';
import 'package:crab_mobile/features/food/presentation/bloc/food_bloc.dart';
import 'package:crab_mobile/features/food/presentation/bloc/food_event.dart';
import 'package:crab_mobile/features/food/presentation/bloc/food_state.dart';

import 'package:crab_mobile/features/payment/data/repositories/payment_repository.dart';
import 'package:crab_mobile/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:crab_mobile/features/payment/presentation/bloc/payment_event.dart';
import 'package:crab_mobile/features/payment/presentation/bloc/payment_state.dart';

import 'package:crab_mobile/features/chat/data/repositories/chat_repository.dart';
import 'package:crab_mobile/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:crab_mobile/features/chat/presentation/bloc/chat_event.dart';
import 'package:crab_mobile/features/chat/presentation/bloc/chat_state.dart';

import 'package:crab_mobile/features/notifications/data/repositories/notification_repository.dart';
import 'package:crab_mobile/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:crab_mobile/features/notifications/presentation/bloc/notification_event.dart';
import 'package:crab_mobile/features/notifications/presentation/bloc/notification_state.dart';

import 'package:crab_mobile/features/profile/data/repositories/profile_repository.dart';
import 'package:crab_mobile/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:crab_mobile/features/profile/presentation/bloc/profile_event.dart';
import 'package:crab_mobile/features/profile/presentation/bloc/profile_state.dart';

import 'package:crab_mobile/features/rating/data/repositories/rating_repository.dart';
import 'package:crab_mobile/features/rating/presentation/bloc/rating_bloc.dart';
import 'package:crab_mobile/features/rating/presentation/bloc/rating_event.dart';
import 'package:crab_mobile/features/rating/presentation/bloc/rating_state.dart';

// ═══════════════════════════════════════════════════════════════
// INFRASTRUCTURE MOCKS
// ═══════════════════════════════════════════════════════════════

class MockDio extends Mock implements Dio {}

class MockDioClient extends Mock implements DioClient {}

class MockAuthStorage extends Mock implements AuthStorage {}

class MockSocketClient extends Mock implements SocketClient {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

// ═══════════════════════════════════════════════════════════════
// REPOSITORY MOCKS
// ═══════════════════════════════════════════════════════════════

class MockAuthRepository extends Mock implements AuthRepository {}

class MockRideRepository extends Mock implements RideRepository {}

class MockDriverRepository extends Mock implements DriverRepository {}

class MockFoodRepository extends Mock implements FoodRepository {}

class MockPaymentRepository extends Mock implements PaymentRepository {}

class MockChatRepository extends Mock implements ChatRepository {}

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockRatingRepository extends Mock implements RatingRepository {}

// ═══════════════════════════════════════════════════════════════
// BLOC MOCKS (for widget tests)
// ═══════════════════════════════════════════════════════════════

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockHomeBloc extends MockBloc<HomeEvent, HomeState> implements HomeBloc {}

class MockRideBloc extends MockBloc<RideEvent, RideState> implements RideBloc {}

class MockDriverBloc extends MockBloc<DriverEvent, DriverState>
    implements DriverBloc {}

class MockFoodBloc extends MockBloc<FoodEvent, FoodState> implements FoodBloc {}

class MockPaymentBloc extends MockBloc<PaymentEvent, PaymentState>
    implements PaymentBloc {}

class MockChatBloc extends MockBloc<ChatEvent, ChatState> implements ChatBloc {}

class MockNotificationBloc
    extends MockBloc<NotificationEvent, NotificationState>
    implements NotificationBloc {}

class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState>
    implements ProfileBloc {}

class MockRatingBloc extends MockBloc<RatingEvent, RatingState>
    implements RatingBloc {}

// ═══════════════════════════════════════════════════════════════
// FAKE CLASSES (for registerFallbackValue)
// ═══════════════════════════════════════════════════════════════

class FakeRequestOptions extends Fake implements RequestOptions {}

class FakeUri extends Fake implements Uri {}
