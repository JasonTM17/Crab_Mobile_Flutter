import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeTabChanged extends HomeEvent {
  final int tabIndex;

  const HomeTabChanged(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}
