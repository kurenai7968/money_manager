import 'package:equatable/equatable.dart';
import 'package:money_manager/models/app_setting.dart';

enum AppSettingStatus { initial, loading, success, failure }

class AppSettingState extends Equatable {
  const AppSettingState({
    this.status = AppSettingStatus.initial,
    this.setting = const AppSetting(),
  });

  final AppSettingStatus status;
  final AppSetting setting;

  AppSettingState copyWith({AppSettingStatus? status, AppSetting? setting}) {
    return AppSettingState(
      status: status ?? this.status,
      setting: setting ?? this.setting,
    );
  }

  @override
  List<Object?> get props => [status, setting];
}
