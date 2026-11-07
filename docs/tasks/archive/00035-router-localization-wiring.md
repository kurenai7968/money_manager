---
id: "00035"
status: done
reads:
  - docs/architecture.md
  - lib/app.dart
  - lib/routes/app_router.dart
  - lib/l10n/locale_resolution.dart
  - lib/l10n/app_localizations.dart
  - test/support/pump_app.dart
---

# Wire router and localization fields

## Outcome

`MaterialApp.router` uses `AppLocalizations.localizationsDelegates`, `AppLocalizations.supportedLocales`, and the router's parser, delegate, provider, and back-button dispatcher. Language and theme still come from `AppSettingBloc`. `localeResolutionCallback` is gone. One `GoRouter` lives for the process, and widget tests start from a new one.

## Out of scope

Route table, theme, and the settings language choices.

## Done when

- [x] `MaterialApp.router` no longer sets `routerConfig` or `localeResolutionCallback`
- [x] System back still uses the `GoRouter` back-button dispatcher
- [x] `flutter test` passes

## Result

`MaterialApp.router` takes the generated localization delegates plus `GlobalMaterialLocalizations.delegates` from `material_ui`, and the four `GoRouter` router fields. `locale` still comes from `AppSettingBloc`. `resolveLocale` is removed. `AppRouter.router` is created once, and widget tests call `AppRouter.reset()` before pumping `App`. `flutter test` passed: 110 tests.
