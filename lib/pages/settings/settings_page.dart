import 'package:material_ui/material_ui.dart';
import 'package:money_manager/pages/settings/widgets/settings_app_bar.dart';
import 'package:money_manager/pages/settings/widgets/settings_body.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(appBar: SettingsAppBar(), body: SettingsBody());
  }
}
