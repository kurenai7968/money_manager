---
id: "00059"
status: done
reads:
  - docs/architecture.md
  - lib/pages/home/widgets/home_app_bar.dart
  - lib/core/utils/cached_date_format.dart
  - test/widget_test.dart
---

# Home month as yyyy-MM

## Outcome

The home title shows the selected month as `yyyy-MM`.

## Out of scope

The record date picker and other date labels.

## Done when

- [x] The home title uses `yyyy-MM`
- [x] `flutter test` passes

## Result

The home title formats the selected month as `yyyy-MM`. The record date picker is unchanged. `flutter test` passed (113). `synced_commit` is unchanged because the worktree is not clean.
