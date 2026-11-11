---
id: "00055"
status: done
reads:
  - docs/architecture.md
  - lib/pages/accounts/widgets/account_detail_app_bar.dart
  - lib/pages/accounts/widgets/account_form_app_bar.dart
  - lib/pages/accounts/widgets/accounts_app_bar.dart
  - lib/pages/analysis/widgets/analysis_app_bar.dart
  - lib/pages/categories/widgets/categories_app_bar.dart
  - lib/pages/categories/widgets/category_form_app_bar.dart
  - lib/pages/home/widgets/home_app_bar.dart
  - lib/pages/record/widgets/record_app_bar.dart
  - lib/pages/settings/widgets/settings_app_bar.dart
  - lib/themes/app_themes.dart
---

# Extract a shared app bar

## Outcome

Page app bars build a shared `BaseAppBar` in `lib/widgets/base_app_bar.dart`. Titles, leading controls, actions, and bottom bars stay the same.

## Out of scope

App bar theme, screen titles, and navigation.

## Done when

- [x] Every page app bar uses `BaseAppBar`
- [x] Titles, leading controls, actions, and bottom bars stay the same
- [x] `flutter test` passes

## Result

`lib/widgets/base_app_bar.dart` builds the `AppBar` for every page. The title is a widget, so the home month controls and the record date button stay in the title. Analysis, categories, and record pass their existing bottom bar. Leading controls and actions are unchanged. `flutter test` passed.
