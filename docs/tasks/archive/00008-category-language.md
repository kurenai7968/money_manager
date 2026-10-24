---
id: "00008"
status: done
reads:
  - docs/architecture.md
  - lib/models/category_model.dart
  - lib/models/category_defaults.dart
  - lib/entities/category_entity.dart
  - lib/database/sqlite/app_database.dart
  - lib/repositories/category_repository.dart
  - lib/pages/categories/bloc/categories_bloc.dart
  - lib/app.dart
---

# Category language

## Outcome

One category row holds every language name. An initial category stores `languageEn`, `languageZh`, and `languageZhCn`, and has no `name`. `languageZh` is Traditional Chinese for both `zh` and `zh_TW`. `languageZhCn` is Simplified Chinese. A category the user creates stores `name` and leaves the language fields empty. The language columns have no default.

## Out of scope

Account and transaction storage.

## Done when

- [x] An initial category stores `languageEn`, `languageZh`, and `languageZhCn` on one row and has no `name`
- [x] A category the user creates stores `name` and leaves the language fields empty
- [x] The categories table adds those language columns with no default
- [x] Traditional Chinese uses `languageZh`, and Simplified Chinese uses `languageZhCn`
- [x] `flutter test` passes

## Result

An initial category is one row with `languageEn`, `languageZh`, and `languageZhCn`, and no `name`. `zh` and `zh_TW` both read `languageZh`. Simplified Chinese reads `languageZhCn`. A category the user creates stores `name` only. The new columns have no default, and an existing category keeps its name. Settings can select Simplified Chinese. `flutter test` passed.
