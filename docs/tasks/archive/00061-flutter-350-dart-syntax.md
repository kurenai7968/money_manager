---
id: "00061"
status: done
reads:
  - docs/architecture.md
---

# Follow Flutter 3.50 and Dart constructor syntax

## Outcome

The Android project uses the Flutter 3.50 toolchain: Gradle 9.5.0, Android Gradle Plugin 9.3.1, and Kotlin 2.4.20. Hand-written constructors use the abbreviated Dart form (`new`, `const new`, `factory`, `new name`) so the type name is not repeated. Fields stay before the constructor.

## Out of scope

Primary constructors, which would move fields into the class header. Behavior, layout, data flow, models, widgets, and blocs stay the same. Generated localization and `*.g.dart` files stay as the generators emit them.

## Done when

- [x] Android Gradle Plugin is 9.3.1, Gradle is 9.5.0, and Kotlin is 2.4.20
- [x] Hand-written constructors omit the repeated type name
- [x] `flutter test` passes

## Result

Android Gradle Plugin is 9.3.1, Gradle is 9.5.0, and Kotlin is 2.4.20, matching the Flutter 3.50 app template. `analysis_options.yaml` enables `unnecessary_type_name_in_constructor`. Hand-written constructors in 107 files now use the abbreviated form, including `const new`, `factory fromJson`, and `new _`. Fields stay before those constructors. Generated localization and `*.g.dart` files are unchanged. `flutter test` passed: 114 tests.
