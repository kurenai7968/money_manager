---
id: "00002"
status: done
reads:
  - docs/architecture.md
  - DESIGN.md
---

# Theme and navigation shell

## Outcome

The app opens on Home with a centered month title, one action that switches summary and calendar, and the shared tab bar. The center button opens the record page and hides the tab bar. Analysis, Accounts, and Settings are reachable and use the same bar and centered titles. Light and dark themes follow `DESIGN.md`.

## Out of scope

Accounts, categories, transactions, persistence, and the record keypad.

## Done when

- [x] Home, Analysis, Accounts, Settings, and Record use the shared chrome
- [x] `flutter test` passes

## Result

The app opens on Home with a centered month title, month switching, and one action that toggles the summary and calendar icons. Analysis, Accounts, and Settings share the tab bar and centered titles. The center button opens Record and hides the tab bar. Light and dark themes are in `AppThemes`. `flutter test` passed.
