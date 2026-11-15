---
id: "00062"
status: done
reads:
  - docs/architecture.md
---

# Restore constructor names

## Outcome

Hand-written constructors use the class name again. The abbreviated `new` form is gone, and the lint that requires it is off. Fields stay before the constructor. The Flutter 3.50 Android toolchain versions from 00061 stay.

## Out of scope

Android Gradle Plugin, Gradle, and Kotlin versions. Primary constructors. Behavior, layout, data flow, models, widgets, and blocs.

## Done when

- [x] Constructor declarations use the class name
- [x] `unnecessary_type_name_in_constructor` is not enabled
- [x] `flutter test` passes

## Result

Constructor declarations use the class name again, such as `const AccountModel(...)` and `factory AccountEntity.fromJson(...)`. `unnecessary_type_name_in_constructor` is not enabled. The Android Gradle Plugin 9.3.1, Gradle 9.5.0, and Kotlin 2.4.20 versions from 00061 remain. `flutter test` passed: 114 tests.
