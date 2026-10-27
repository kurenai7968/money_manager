import 'package:material_ui/material_ui.dart';

enum AppAppearance {
  system,
  light,
  dark;

  ThemeMode get themeMode => switch (this) {
    AppAppearance.system => ThemeMode.system,
    AppAppearance.light => ThemeMode.light,
    AppAppearance.dark => ThemeMode.dark,
  };
}
