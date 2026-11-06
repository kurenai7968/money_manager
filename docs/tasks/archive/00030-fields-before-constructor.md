---
id: "00030"
status: done
reads:
  - docs/architecture.md
  - lib/models/app_setting_model.dart
---

# Fields before constructors

## Outcome

Hand-written classes declare their fields before their constructors, in the same order as `AppSettingModel`.

## Out of scope

Generated localization and `*.g.dart` files. Behavior, layout, and data flow stay the same.

## Done when

- [x] Hand-written classes put fields before constructors
- [x] `flutter test` passes

## Result

Hand-written classes now declare fields before constructors, including static fields. Generated localization and `*.g.dart` files are unchanged. The Invariants section now says to declare fields before the constructor. `flutter test` passed: 104 tests.
