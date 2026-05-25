import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crab_mobile/features/home/presentation/bloc/home_bloc.dart';
import 'package:crab_mobile/features/home/presentation/bloc/home_event.dart';
import 'package:crab_mobile/features/home/presentation/bloc/home_state.dart';

void main() {
  group('HomeBloc', () {
    test('initial state has currentTabIndex 0', () {
      final bloc = HomeBloc();
      expect(bloc.state.currentTabIndex, 0);
      bloc.close();
    });

    blocTest<HomeBloc, HomeState>(
      'emits state with new tab index on HomeTabChanged',
      build: () => HomeBloc(),
      act: (bloc) => bloc.add(const HomeTabChanged(2)),
      expect: () => [const HomeState(currentTabIndex: 2)],
    );

    blocTest<HomeBloc, HomeState>(
      'handles multiple tab changes in sequence',
      build: () => HomeBloc(),
      act: (bloc) {
        bloc.add(const HomeTabChanged(1));
        bloc.add(const HomeTabChanged(3));
        bloc.add(const HomeTabChanged(0));
      },
      expect: () => [
        const HomeState(currentTabIndex: 1),
        const HomeState(currentTabIndex: 3),
        const HomeState(currentTabIndex: 0),
      ],
    );
  });
}
