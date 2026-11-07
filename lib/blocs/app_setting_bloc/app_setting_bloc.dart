import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_event.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_state.dart';
import 'package:money_manager/core/errors/app_exception.dart';
import 'package:money_manager/models/app_setting_model.dart';
import 'package:money_manager/repositories/app_setting_repository.dart';

class AppSettingBloc extends Bloc<AppSettingEvent, AppSettingState> {
  final AppSettingRepository appSettingRepository;

  AppSettingBloc({required this.appSettingRepository})
    : super(const AppSettingState()) {
    on<AppSettingInitialized>(_onAppSettingInitialized);
    on<AppSettingLanguageChanged>(_onAppSettingLanguageChanged);
    on<AppSettingThemeModeChanged>(_onAppSettingThemeModeChanged);
    on<AppSettingFirstDayOfWeekChanged>(_onAppSettingFirstDayOfWeekChanged);
    add(const AppSettingInitialized());
  }

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

  Future<void> _onAppSettingLanguageChanged(
    AppSettingLanguageChanged event,
    Emitter<AppSettingState> emit,
  ) async {
    final updatedSetting = state.appSetting.copyWith(
      languageCode: event.languageCode,
      countryCode: event.countryCode,
    );
    await _appSettingUpdate(updatedSetting, emit);
  }

  Future<void> _onAppSettingThemeModeChanged(
    AppSettingThemeModeChanged event,
    Emitter<AppSettingState> emit,
  ) async {
    final updatedSetting = state.appSetting.copyWith(
      appThemeMode: event.appThemeMode,
    );
    await _appSettingUpdate(updatedSetting, emit);
  }

  Future<void> _onAppSettingFirstDayOfWeekChanged(
    AppSettingFirstDayOfWeekChanged event,
    Emitter<AppSettingState> emit,
  ) async {
    final updatedSetting = state.appSetting.copyWith(
      firstDayOfWeek: event.firstDayOfWeek,
    );
    await _appSettingUpdate(updatedSetting, emit);
  }

  Future<void> _appSettingUpdate(
    AppSettingModel updatedSetting,
    Emitter<AppSettingState> emit,
  ) async {
    try {
      await appSettingRepository.updateAppSetting(updatedSetting);
      emit(
        state.copyWith(
          status: AppSettingStatus.success,
          appSetting: updatedSetting,
        ),
      );
    } on AppException {
      emit(state.copyWith(status: AppSettingStatus.failure));
    }
  }
}
