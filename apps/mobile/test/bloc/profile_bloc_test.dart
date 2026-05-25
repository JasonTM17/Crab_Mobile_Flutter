import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crab_mobile/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:crab_mobile/features/profile/presentation/bloc/profile_event.dart';
import 'package:crab_mobile/features/profile/presentation/bloc/profile_state.dart';
import 'package:crab_mobile/features/profile/data/models/user_profile_model.dart';

import '../helpers/mocks.dart';
import '../helpers/fixtures.dart';

void main() {
  late MockProfileRepository mockRepo;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockRepo = MockProfileRepository();
    mockStorage = MockFlutterSecureStorage();
  });

  group('ProfileBloc', () {
    test('initial state is ProfileInitial', () {
      final bloc = ProfileBloc(mockRepo, mockStorage);
      expect(bloc.state, isA<ProfileInitial>());
      bloc.close();
    });

    group('LoadProfile', () {
      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileLoading, ProfileLoaded] on success',
        build: () {
          when(() => mockRepo.getProfile())
              .thenAnswer((_) async => tUserProfile);
          return ProfileBloc(mockRepo, mockStorage);
        },
        act: (bloc) => bloc.add(const LoadProfile()),
        expect: () => [
          isA<ProfileLoading>(),
          isA<ProfileLoaded>()
              .having((s) => s.profile.fullName, 'name', 'Nguyen Van A')
              .having((s) => s.profile.email, 'email', tEmail),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileLoading, ProfileError] on failure',
        build: () {
          when(() => mockRepo.getProfile()).thenThrow(Exception('Error'));
          return ProfileBloc(mockRepo, mockStorage);
        },
        act: (bloc) => bloc.add(const LoadProfile()),
        expect: () => [
          isA<ProfileLoading>(),
          isA<ProfileError>(),
        ],
      );
    });

    group('UpdateProfile', () {
      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileLoading, ProfileUpdated] on success',
        build: () {
          final updated = UserProfileModel(
            id: tUserProfile.id,
            email: tUserProfile.email,
            fullName: 'New Name',
            phone: tUserProfile.phone,
            role: tUserProfile.role,
            isVerified: tUserProfile.isVerified,
            createdAt: tUserProfile.createdAt,
          );
          when(() => mockRepo.updateProfile(
                fullName: 'New Name',
                phone: any(named: 'phone'),
              )).thenAnswer((_) async => updated);
          return ProfileBloc(mockRepo, mockStorage);
        },
        act: (bloc) => bloc.add(const UpdateProfile(fullName: 'New Name')),
        expect: () => [
          isA<ProfileLoading>(),
          isA<ProfileUpdated>()
              .having((s) => s.profile.fullName, 'name', 'New Name'),
        ],
      );
    });

    group('ChangePassword', () {
      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileLoading, PasswordChanged] on success',
        build: () {
          when(() => mockRepo.changePassword(
                currentPassword: 'old123',
                newPassword: 'new456',
              )).thenAnswer((_) async {});
          return ProfileBloc(mockRepo, mockStorage);
        },
        act: (bloc) => bloc.add(const ChangePassword(
          currentPassword: 'old123',
          newPassword: 'new456',
        )),
        expect: () => [
          isA<ProfileLoading>(),
          isA<PasswordChanged>(),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileLoading, ProfileError] on wrong password',
        build: () {
          when(() => mockRepo.changePassword(
                currentPassword: 'wrong',
                newPassword: 'new456',
              )).thenThrow(Exception('Wrong password'));
          return ProfileBloc(mockRepo, mockStorage);
        },
        act: (bloc) => bloc.add(const ChangePassword(
          currentPassword: 'wrong',
          newPassword: 'new456',
        )),
        expect: () => [
          isA<ProfileLoading>(),
          isA<ProfileError>(),
        ],
      );
    });

    group('LogoutRequested', () {
      blocTest<ProfileBloc, ProfileState>(
        'emits LoggedOut and clears storage',
        build: () {
          when(() => mockStorage.delete(key: any(named: 'key')))
              .thenAnswer((_) async {});
          return ProfileBloc(mockRepo, mockStorage);
        },
        act: (bloc) => bloc.add(const LogoutRequested()),
        expect: () => [isA<LoggedOut>()],
        verify: (_) {
          verify(() => mockStorage.delete(key: any(named: 'key'))).called(2);
        },
      );
    });
  });
}
