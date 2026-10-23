import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_event.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_state.dart';
import 'package:money_manager/database/shared_preferences/settings_store.dart';

class AppSettingBloc extends Bloc<AppSettingEvent, AppSettingState> {
  AppSettingBloc(this._store) : super(const AppSettingState()) {
    on<AppSettingStarted>(_onStarted);
    on<AppSettingChanged>(_onChanged);
  }

  final SettingsStore _store;

  Future<void> _onStarted(
    AppSettingStarted event,
    Emitter<AppSettingState> emit,
  ) async {
    emit(state.copyWith(status: AppSettingStatus.loading));
    try {
      emit(
        state.copyWith(
          status: AppSettingStatus.success,
          setting: await _store.load(),
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: AppSettingStatus.failure));
    }
  }

  Future<void> _onChanged(
    AppSettingChanged event,
    Emitter<AppSettingState> emit,
  ) async {
    await _store.save(event.setting);
    emit(
      state.copyWith(status: AppSettingStatus.success, setting: event.setting),
    );
  }
}
