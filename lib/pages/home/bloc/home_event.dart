import 'package:equatable/equatable.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeStarted extends HomeEvent {
  const HomeStarted();
}

class HomeMonthShifted extends HomeEvent {
  const HomeMonthShifted(this.delta);

  final int delta;

  @override
  List<Object?> get props => [delta];
}

class HomeViewToggled extends HomeEvent {
  const HomeViewToggled();
}

class HomeDaySelected extends HomeEvent {
  const HomeDaySelected(this.day);

  final DateTime day;

  @override
  List<Object?> get props => [day];
}

class HomeSourcesChanged extends HomeEvent {
  const HomeSourcesChanged();
}
