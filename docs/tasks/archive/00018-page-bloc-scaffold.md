---
id: "00018"
status: done
reads:
  - docs/architecture.md
  - lib/app.dart
  - lib/app_providers.dart
  - lib/pages/home/home_page.dart
  - lib/pages/analysis/analysis_page.dart
  - lib/pages/accounts/accounts_page.dart
  - lib/pages/accounts/account_form_page.dart
  - lib/pages/accounts/account_detail_page.dart
  - lib/pages/categories/categories_page.dart
  - lib/pages/categories/category_form_page.dart
  - lib/pages/record/record_page.dart
  - lib/pages/settings/settings_page.dart
---

# Thin page with its bloc

## Outcome

A page file only creates the blocs that screen uses and returns a scaffold. The app bar and body are separate widgets. `AppSettingBloc` stays above the router. A page that stays mounted reloads its blocs when the route changes.

## Out of scope

Bloc event names, repositories, and screen behavior stay the same.

## Done when

- [x] Each `*_page.dart` builds its bloc provider and a scaffold with a separate app bar and body
- [x] `docs/architecture.md` describes that page shape
- [x] `flutter test` passes

## Result

Page files create the blocs that screen uses and return a scaffold whose app bar and body are separate widgets. `AppSettingBloc` stays in `AppProviders`. A mounted page reloads its blocs when the route changes. `flutter test` passed.
