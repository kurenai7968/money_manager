---
id: "00060"
status: done
reads:
  - docs/architecture.md
  - DESIGN.md
  - lib/pages/home/widgets/home_app_bar.dart
  - lib/widgets/base_app_bar.dart
  - test/home/home_account_test.dart
---

# Home bar account room

## Outcome

The home account control shows its label. A long name keeps the beginning and ellipsizes the rest. The month stays centered, and its step buttons take less width.

## Out of scope

Record, analysis, and the other app bars.

## Done when

- [x] On a phone-width home bar, the account label is visible and does not sit under the month
- [x] A long account name shows its beginning
- [x] `flutter test` passes

## Result

The home account label sits on the leading side of the centered month and no longer falls under the month controls. A long name keeps its beginning and ellipsizes the rest. The month step buttons and the summary action are 32 wide. `flutter test` passed (114). `synced_commit` is unchanged because the worktree is not clean.
