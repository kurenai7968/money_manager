---
id: "00009"
status: done
reads:
  - docs/architecture.md
  - lib/models/account_model.dart
  - lib/models/app_setting.dart
  - lib/pages/accounts/bloc/accounts_bloc.dart
  - lib/pages/settings/settings_page.dart
  - lib/database/shared_preferences/settings_store.dart
  - lib/database/sqlite/app_database.dart
---

# Default account

## Outcome

An empty ledger gets one cash account with `languageEn`, `languageZh`, and `languageZhCn`, and no `name`. Settings no longer stores or edits a currency. Amounts stay plain numbers. Traditional Chinese uses `app_zh.arb` only.

## Out of scope

Transaction rules, category languages, and appearance settings.

## Done when

- [x] A new database has one cash account with opening balance 0
- [x] That account stores `languageEn`, `languageZh`, and `languageZhCn` and has no `name`
- [x] An account the user creates still stores `name`
- [x] Settings has no currency row, and `AppSetting` has no currency
- [x] `app_zh_TW.arb` is removed
- [x] `flutter test` passes

## Result

An empty ledger gets one cash account with `languageEn` Cash, `languageZh` 現金, and `languageZhCn` 现金, and no `name`. A user-created account stores `name` only. Settings no longer stores or edits a currency. `app_zh_TW.arb` is removed; Traditional Chinese stays on `app_zh.arb`, and a `zh_TW` device still uses `languageZh`. `flutter test` passed.
