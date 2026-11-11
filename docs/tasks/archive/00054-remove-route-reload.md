---
id: "00054"
status: done
reads:
  - docs/architecture.md
  - lib/pages/route_reload.dart
  - lib/pages/home/widgets/home_body.dart
  - lib/pages/analysis/widgets/analysis_body.dart
  - lib/pages/accounts/widgets/accounts_body.dart
  - lib/pages/accounts/widgets/account_detail_body.dart
  - lib/pages/categories/widgets/categories_body.dart
  - lib/routes/app_router.dart
  - test/support/pump_app.dart
  - test/record/record_page_test.dart
  - test/widget_test.dart
---

# Remove RouteReload

## Outcome

Remove the `RouteReload` mixin. Page bodies no longer listen to the router and redispatch their start event when the route changes.

## Out of scope

Changing how a page creates its bloc or dispatches the start event the first time. Changing shell routes.

## Done when

- [x] `lib/pages/route_reload.dart` is gone, and no page body mixes it in
- [x] `flutter test` passes

## Result

`lib/pages/route_reload.dart` is gone. Home, analysis, accounts, account detail, and categories bodies are stateless widgets and no longer redispatch their start event when the route changes. Data flow in `docs/architecture.md` no longer says a mounted page reloads on route change. Widget tests that returned to a mounted page call `reopenApp`, which builds a new page from the same database. `flutter test` passed (118). `synced_commit` is unchanged because the worktree is not clean.
