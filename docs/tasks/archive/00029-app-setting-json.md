---
id: "00029"
status: done
reads:
  - docs/architecture.md
  - lib/repositories/app_setting_repository.dart
  - lib/models/app_setting_model.dart
  - lib/entities/account_entity.dart
  - lib/core/mapping/account_mapping.dart
  - lib/app.dart
  - lib/pages/settings/widgets/settings_body.dart
---

# Store app settings as JSON

## Outcome

App settings load and save as one JSON value. The value has a language code, a country code, appearance, and the first day of the week. An empty language code follows the system locale. The settings screen and the app locale use the language code and the country code together.

## Out of scope

Calendar day layout, dependency versions, deferred localization loading, and analysis option comments.

## Done when

- [x] A saved setting round-trips through one JSON value
- [x] An empty language code stays empty and its locale is null
- [x] Invalid JSON and an unrecognized appearance throw `CacheException`
- [x] The language sheet writes a language code and a country code
- [x] `flutter test` passes

## Result

App settings are one JSON object under `app_setting`, mapped through `AppSettingEntity`. An empty language code follows the system locale. Traditional Chinese is `zh`, simplified Chinese is `zh` and `CN`, and English is `en`. The settings sheet writes both codes, and the app applies `AppSettingModel.locale`. `flutter test` passed: 104 tests.
