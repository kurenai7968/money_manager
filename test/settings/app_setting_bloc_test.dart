import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_bloc.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_event.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_state.dart';
import 'package:money_manager/core/errors/app_exception.dart';
import 'package:money_manager/models/app_setting_model.dart';
import 'package:money_manager/models/enums/app_appearance.dart';
import 'package:money_manager/models/enums/first_day_of_week.dart';
import 'package:table_calendar/table_calendar.dart';
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
  Future<void> updateAppSetting(AppSettingModel appSetting) async {
    if (failWrites) {
      throw const CacheException('write failed');
    }
    this.appSetting = appSetting;
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
    'saves an appearance change',
    build: () => AppSettingBloc(appSettingRepository: repository),
    act: (bloc) => bloc.add(
      const AppSettingChanged(AppSettingModel(appearance: AppAppearance.dark)),
    ),
    expect: () => const [
      AppSettingState(status: AppSettingStatus.loading),
      AppSettingState(status: AppSettingStatus.success),
      AppSettingState(
        status: AppSettingStatus.success,
        appSetting: AppSettingModel(appearance: AppAppearance.dark),
      ),
    ],
    verify: (bloc) {
      expect(bloc.state.appSetting.appearance, AppAppearance.dark);
      expect(repository.appSetting.appearance, AppAppearance.dark);
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
      const AppSettingChanged(AppSettingModel(appearance: AppAppearance.light)),
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
