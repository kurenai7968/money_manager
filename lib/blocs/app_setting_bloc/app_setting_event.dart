import 'package:equatable/equatable.dart';
import 'package:money_manager/models/app_setting_model.dart';

sealed class AppSettingEvent extends Equatable {
  const AppSettingEvent();

  @override
  List<Object?> get props => [];
}

class AppSettingInitialized extends AppSettingEvent {
  const AppSettingInitialized();
}

class AppSettingChanged extends AppSettingEvent {
  const AppSettingChanged(this.appSetting);

  final AppSettingModel appSetting;

  @override
  List<Object?> get props => [appSetting];
}
