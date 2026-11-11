import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_bloc.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_event.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_state.dart';
import 'package:money_manager/core/errors/app_exception.dart';
import 'package:money_manager/models/app_setting_model.dart';
import 'package:money_manager/models/enums/app_theme_mode.dart';
import 'package:money_manager/models/enums/first_day_of_week.dart';
import 'package:money_manager/repositories/app_setting_repository.dart';

class _MemoryAppSettingRepository implements AppSettingRepository {
  AppSettingModel appSetting = const AppSettingModel();
  var failReads = false;
  var failWrites = false;

  @override
  Future<AppSettingModel> getAppSetting() async {
    if (failReads) {
      throw const CacheException('read failed');
    }
    return appSetting;
  }

  @override
  Future<AppSettingModel> updateLanguage(
    String languageCode,
    String countryCode,
  ) {
    return _write(
      appSetting.copyWith(
        languageCode: languageCode,
        countryCode: countryCode,
      ),
    );
  }

  @override
  Future<AppSettingModel> updateThemeMode(AppThemeMode appThemeMode) {
    return _write(appSetting.copyWith(appThemeMode: appThemeMode));
  }

  @override
  Future<AppSettingModel> updateFirstDayOfWeek(FirstDayOfWeek firstDayOfWeek) {
    return _write(appSetting.copyWith(firstDayOfWeek: firstDayOfWeek));
  }

  Future<AppSettingModel> _write(AppSettingModel next) async {
    if (failWrites) {
      throw const CacheException('write failed');
    }
    appSetting = next;
    return appSetting;
  }
}

void main() {
  late _MemoryAppSettingRepository repository;

  setUp(() {
    repository = _MemoryAppSettingRepository();
  });

  blocTest<AppSettingBloc, AppSettingState>(
    'loads the default setting',
    build: () => AppSettingBloc(appSettingRepository: repository),
    expect: () => const [
      AppSettingState(status: AppSettingStatus.loading),
      AppSettingState(status: AppSettingStatus.success),
    ],
  );

  blocTest<AppSettingBloc, AppSettingState>(
    'saves a theme mode change',
    build: () => AppSettingBloc(appSettingRepository: repository),
    act: (bloc) => bloc.add(
      const AppSettingThemeModeChanged(appThemeMode: AppThemeMode.dark),
    ),
    expect: () => const [
      AppSettingState(status: AppSettingStatus.loading),
      AppSettingState(status: AppSettingStatus.success),
      AppSettingState(
        status: AppSettingStatus.success,
        appSetting: AppSettingModel(appThemeMode: AppThemeMode.dark),
      ),
    ],
    verify: (bloc) {
      expect(bloc.state.appSetting.appThemeMode, AppThemeMode.dark);
      expect(repository.appSetting.appThemeMode, AppThemeMode.dark);
    },
  );

  blocTest<AppSettingBloc, AppSettingState>(
    'emits failure when the setting cannot be read',
    build: () {
      repository.failReads = true;
      return AppSettingBloc(appSettingRepository: repository);
    },
    expect: () => const [
      AppSettingState(status: AppSettingStatus.loading),
      AppSettingState(status: AppSettingStatus.failure),
    ],
  );

  blocTest<AppSettingBloc, AppSettingState>(
    'emits failure when the setting cannot be saved',
    build: () {
      repository.failWrites = true;
      return AppSettingBloc(appSettingRepository: repository);
    },
    act: (bloc) => bloc.add(
      const AppSettingThemeModeChanged(appThemeMode: AppThemeMode.light),
    ),
    expect: () => const [
      AppSettingState(status: AppSettingStatus.loading),
      AppSettingState(status: AppSettingStatus.success),
      AppSettingState(status: AppSettingStatus.failure),
    ],
  );

  test('each first day maps to the same calendar weekday', () {
    for (final day in FirstDayOfWeek.values) {
      expect(day.toStartingDayOfWeek().name, day.name);
    }
  });

  test('blanks follow the first day of the week', () {
    expect(
      leadingCalendarBlanks(DateTime(2026, 10, 1), FirstDayOfWeek.monday),
      3,
    );
    expect(
      leadingCalendarBlanks(DateTime(2026, 10, 1), FirstDayOfWeek.sunday),
      4,
    );
    expect(
      leadingCalendarBlanks(DateTime(2026, 10, 1), FirstDayOfWeek.thursday),
      0,
    );
    expect(
      leadingCalendarBlanks(DateTime(2026, 10, 1), FirstDayOfWeek.friday),
      6,
    );
  });
}
