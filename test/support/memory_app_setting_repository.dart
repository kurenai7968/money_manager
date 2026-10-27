import 'package:money_manager/models/app_setting_model.dart';
import 'package:money_manager/repositories/app_setting_repository.dart';

class MemoryAppSettingRepository implements AppSettingRepository {
  AppSettingModel appSetting = const AppSettingModel();

  @override
  Future<AppSettingModel> getAppSetting() async => appSetting;

  @override
  Future<void> updateAppSetting(AppSettingModel appSetting) async {
    this.appSetting = appSetting;
  }
}
