import 'package:flutter/widgets.dart';
import 'package:money_manager/l10n/app_localizations.dart';

extension ContextExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
