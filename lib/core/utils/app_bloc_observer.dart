import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  final bool logOnCreate;
  final bool logOnEvent;
  final bool logOnChange;
  final bool logOnTransition;
  final bool logOnError;
  final bool logOnClose;

  AppBlocObserver({
    this.logOnCreate = true,
    this.logOnEvent = true,
    this.logOnChange = true,
    this.logOnTransition = true,
    this.logOnError = true,
    this.logOnClose = true,
  });

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    if (logOnCreate) {
      log('onCreate -- ${bloc.runtimeType}');
    }
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    if (logOnEvent) {
      log('onEvent -- ${bloc.runtimeType}, $event');
    }
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (logOnChange) {
      log('onChange -- ${bloc.runtimeType}, $change');
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (logOnTransition) {
      log('onTransition -- ${bloc.runtimeType}, $transition');
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    if (logOnError) {
      log('onError -- ${bloc.runtimeType}, $error');
    }
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    if (logOnClose) {
      log('onClose -- ${bloc.runtimeType}');
    }
  }
}
