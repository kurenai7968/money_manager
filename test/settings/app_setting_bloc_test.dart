import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_bloc.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_event.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_state.dart';
import 'package:money_manager/core/errors/app_exception.dart';
import 'package:money_manager/models/app_setting_model.dart';
import 'package:money_manager/models/enums/app_appearance.dart';
import 'package:money_manager/models/enums/week_start.dart';
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

  test('Sunday is the first column when the week starts on Sunday', () {
    expect(leadingCalendarBlanks(DateTime(2026, 10, 1), WeekStart.monday), 3);
    expect(leadingCalendarBlanks(DateTime(2026, 10, 1), WeekStart.sunday), 4);
  });
}
