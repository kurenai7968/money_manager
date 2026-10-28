---
id: "00016"
status: done
reads:
  - docs/architecture.md
  - lib/pages/categories/category_form_page.dart
  - lib/pages/categories/categories_page.dart
  - lib/pages/accounts/accounts_page.dart
  - lib/pages/record/record_page.dart
  - lib/pages/settings/settings_page.dart
  - lib/themes/app_themes.dart
---

# Category icon, reorder, and sheets

## Outcome

The selected category icon is visibly marked. Reordering categories or accounts does not flash the old order. A modal bottom sheet uses the page background color and the root navigator, so the tab bar is covered while it is open.

## Out of scope

New sheet contents, account language fields, and the record page category grid.

## Done when

- [x] The chosen category icon has a visible selected state
- [x] Category and account reordering keeps the new order without flashing the previous one
- [x] Modal bottom sheets match the background and cover the tab bar
- [x] `flutter test` passes

## Result

The selected category icon is a filled circle in the category color. Category and account lists apply a drag immediately and keep that order until the saved list matches, and the dragged row uses the page background. Modal sheets use that same background and the root navigator, so the tab bar is covered. `flutter test` passed.
