import 'package:equatable/equatable.dart';
import 'package:money_manager/models/app_setting_model.dart';

enum AppSettingStatus { initial, loading, success, failure }

class AppSettingState extends Equatable {
  final AppSettingStatus status;
  final AppSettingModel appSetting;

  const AppSettingState({
    this.status = AppSettingStatus.initial,
    this.appSetting = const AppSettingModel(),
  });

  AppSettingState copyWith({
    AppSettingStatus? status,
    AppSettingModel? appSetting,
  }) {
    return AppSettingState(
      status: status ?? this.status,
      appSetting: appSetting ?? this.appSetting,
    );
  }

  @override
  List<Object?> get props => [status, appSetting];
}
