import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_event.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_state.dart';
import 'package:money_manager/core/errors/app_exception.dart';
import 'package:money_manager/repositories/app_setting_repository.dart';

class AppSettingBloc extends Bloc<AppSettingEvent, AppSettingState> {
  AppSettingBloc({required this.appSettingRepository})
    : super(const AppSettingState()) {
    on<AppSettingInitialized>(_onAppSettingInitialized);
    on<AppSettingChanged>(_onAppSettingChanged);
    add(const AppSettingInitialized());
  }

  final AppSettingRepository appSettingRepository;

  Future<void> _onAppSettingInitialized(
    AppSettingInitialized event,
    Emitter<AppSettingState> emit,
  ) async {
    if (state.status == AppSettingStatus.initial) {
      emit(state.copyWith(status: AppSettingStatus.loading));
    }
    try {
      final appSetting = await appSettingRepository.getAppSetting();
      emit(
        state.copyWith(
          status: AppSettingStatus.success,
          appSetting: appSetting,
        ),
      );
    } on AppException {
      emit(state.copyWith(status: AppSettingStatus.failure));
    }
  }

  Future<void> _onAppSettingChanged(
    AppSettingChanged event,
    Emitter<AppSettingState> emit,
  ) async {
    try {
      await appSettingRepository.updateAppSetting(event.appSetting);
      emit(
        state.copyWith(
          status: AppSettingStatus.success,
          appSetting: event.appSetting,
        ),
      );
    } on AppException {
      emit(state.copyWith(status: AppSettingStatus.failure));
    }
  }
}
