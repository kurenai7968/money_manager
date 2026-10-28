---
id: "00017"
status: done
reads:
  - docs/architecture.md
  - lib/pages/record/record_page.dart
  - lib/pages/home/home_page.dart
  - lib/pages/accounts/accounts_page.dart
  - lib/pages/categories/categories_page.dart
  - lib/pages/categories/category_form_page.dart
  - lib/pages/settings/settings_page.dart
  - lib/pages/analysis/analysis_page.dart
---

# Split page widgets

## Outcome

Feature pages keep their page class and move section widgets into `pages/[feature]/widgets/`. Recording, home, accounts, categories, settings, and analysis are included. Visible behavior stays the same.

## Out of scope

Account form and account detail stay as single page classes. Shared widgets in `lib/widgets/` stay unchanged. No change to data flow, models, or blocs.

## Done when

- [x] Section widgets used by one feature live under that feature's `widgets/` folder
- [x] `flutter test` passes

## Result

Record, home, accounts, categories, settings, and analysis section widgets now live under each feature's `widgets/` folder. Page classes stay in the page files. Account form and account detail are unchanged. `flutter test` passed.
