import 'package:equatable/equatable.dart';
import 'package:money_manager/models/app_setting.dart';

sealed class AppSettingEvent extends Equatable {
  const AppSettingEvent();

  @override
  List<Object?> get props => [];
}

class AppSettingStarted extends AppSettingEvent {
  const AppSettingStarted();
}

class AppSettingChanged extends AppSettingEvent {
  const AppSettingChanged(this.setting);

  final AppSetting setting;

  @override
  List<Object?> get props => [setting];
}
