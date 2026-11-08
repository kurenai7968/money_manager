import 'package:flutter_bloc/flutter_bloc.dart';

/// Runs this bloc's handlers one at a time.
///
/// Bloc handles different event types concurrently. A page bloc loads in
/// `Started` and then reads that data from later events, so those events wait
/// until the load has finished.
mixin QueuedBloc<Event, State> on Bloc<Event, State> {
  final _turn = _BlocTurn();

  @override
  void on<E extends Event>(
    EventHandler<E, State> handler, {
    EventTransformer<E>? transformer,
  }) {
    super.on<E>(
      (event, emit) => _turn.run(() async => handler(event, emit)),
      transformer: transformer,
    );
  }
}

class _BlocTurn {
  Future<void> _tail = Future<void>.value();

  Future<void> run(Future<void> Function() action) {
    final done = _tail.then((_) => action());
    _tail = done.then((_) {}, onError: (_, _) {});
    return done;
  }
}
