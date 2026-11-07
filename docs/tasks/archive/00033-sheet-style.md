---
id: "00033"
status: done
reads:
  - docs/architecture.md
  - DESIGN.md
  - lib/widgets/ledger_sheet.dart
  - lib/themes/app_themes.dart
  - lib/pages/home/widgets/home_account_sheet.dart
  - lib/pages/home/widgets/home_app_bar.dart
  - lib/pages/record/widgets/record_account_sheet.dart
  - lib/pages/record/widgets/record_body.dart
  - lib/pages/record/widgets/record_transfer_fields.dart
  - lib/pages/settings/widgets/settings_choice_sheet.dart
  - test/settings/settings_sheet_test.dart
---

# Sheet style

## Outcome

Every modal bottom sheet uses the page background, a 12 top radius, and no shadow. An account sheet is at most half the screen tall and scrolls when the list is longer.

## Out of scope

Sheet contents other than the height of the account sheets. Dialogs.

## Done when

- [x] Settings and account sheets share that chrome
- [x] An account sheet taller than the list stays within half the screen
- [x] `flutter test` passes

## Result

Modal bottom sheets use the page background, a 12 top radius, and no shadow. Home and record account sheets stay within half the screen and scroll. `flutter test` passed.
