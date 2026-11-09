import 'package:equatable/equatable.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeInitialized extends HomeEvent {
  const HomeInitialized();
}

class HomeMonthShifted extends HomeEvent {
  final int delta;

  const HomeMonthShifted(this.delta);

  @override
  List<Object?> get props => [delta];
}

class HomeViewToggled extends HomeEvent {
  const HomeViewToggled();
}

class HomeDaySelected extends HomeEvent {
  final DateTime day;

  const HomeDaySelected(this.day);

  @override
  List<Object?> get props => [day];
}

class HomeAccountSelected extends HomeEvent {
  final String? accountId;

  const HomeAccountSelected(this.accountId);

  @override
  List<Object?> get props => [accountId];
}
