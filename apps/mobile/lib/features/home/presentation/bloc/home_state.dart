import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final int currentTabIndex;

  const HomeState({this.currentTabIndex = 0});

  HomeState copyWith({int? currentTabIndex}) {
    return HomeState(
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
    );
  }

  @override
  List<Object?> get props => [currentTabIndex];
}
