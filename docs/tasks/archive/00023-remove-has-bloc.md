---
id: "00023"
status: done
reads:
  - docs/architecture.md
  - lib/pages/page_blocs.dart
  - lib/pages/home/home_page.dart
  - lib/pages/analysis/analysis_page.dart
  - lib/pages/record/record_page.dart
  - lib/pages/accounts/accounts_page.dart
  - lib/pages/accounts/account_form_page.dart
  - lib/pages/accounts/account_detail_page.dart
  - lib/pages/categories/categories_page.dart
  - lib/pages/categories/category_form_page.dart
---

# Remove hasBloc

## Outcome

Pages create the blocs they use with nested `BlocProvider`s and dispatch start events. They do not check whether an ancestor already provides that bloc. `hasBloc` and `page_blocs.dart` are gone.

## Out of scope

Which blocs a page creates, route reload, and `AppSettingBloc`.

## Done when

- [x] No `hasBloc` remains
- [x] Each page creates its providers in the existing order
- [x] `flutter test` passes

## Result

Pages nest `BlocProvider`s and dispatch start events without checking for an ancestor bloc. `page_blocs.dart` is removed. Provider order is unchanged: accounts, then transactions, then categories.

The category page widget tests were providing a `CategoriesBloc` above the page. They now provide the category and transaction repositories, and read saved categories from the repository. `flutter test` passed.
