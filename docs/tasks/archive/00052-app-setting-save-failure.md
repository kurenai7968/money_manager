---
id: "00052"
status: done
reads:
  - docs/architecture.md
  - lib/blocs/app_setting_bloc/app_setting_bloc.dart
  - lib/repositories/app_setting_repository.dart
  - lib/core/errors/app_exception.dart
  - test/settings/app_setting_bloc_test.dart
  - test/settings/app_setting_repository_test.dart
  - test/support/memory_app_setting_repository.dart
---

# Emit failure when an app setting save fails

## Outcome

When `AppSettingRepository` throws `AppException` while saving language, theme mode, or the first weekday, `AppSettingBloc` emits `AppSettingStatus.failure`.

## Out of scope

Where the repository copies and stores one field. The BLoC section of `docs/architecture.md` still describes the bloc copying the model.

## Done when

- [x] A failed save emits `failure` and leaves the previous setting in state.
- [x] `flutter test` passes

## Result

`AppSettingBloc` awaits the repository save inside `try` and emits `AppSettingStatus.failure` on `AppException`. The previous `appSetting` stays in state. `flutter test` passed: 118 tests.
