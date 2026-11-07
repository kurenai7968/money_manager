---
id: "00034"
status: done
reads:
  - docs/architecture.md
  - lib/app.dart
  - lib/app_providers.dart
  - lib/blocs/app_setting_bloc/app_setting_bloc.dart
  - lib/blocs/app_setting_bloc/app_setting_event.dart
  - lib/models/app_setting_model.dart
  - lib/models/enums/app_theme_mode.dart
  - lib/repositories/account_repository.dart
  - lib/repositories/app_setting_repository.dart
  - lib/repositories/category_repository.dart
  - lib/repositories/transaction_repository.dart
---

# Match code style in the architecture

## Outcome

The architecture describes the current app shell, repository implementation names, theme mode, and per-field app-setting events, so later work follows that style. Tests construct those implementations with named arguments and pump `App` without repository arguments.

## Out of scope

Ledger behavior.

## Done when

- [x] `docs/architecture.md` matches the style in the current app shell, repositories, and app-setting events
- [x] `flutter test` passes

## Result

The architecture now describes the stateless app shell, `[Name]RepositoryImpl` with named constructor arguments, `AppThemeMode`, and one app-setting event per changed field. Repository tests use those named constructors. Widget tests pump `App` with no repository arguments and seed the test database through the implementations. They use a live widget binding so SQLite can finish. `flutter test` passed: 110 tests.
