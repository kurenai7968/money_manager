---
id: "00036"
status: done
reads:
  - docs/architecture.md
  - lib/app.dart
---

# Document localization delegates

## Outcome

The Tech stack localization sentence names `AppLocalizations.localizationsDelegates` and `GlobalMaterialLocalizations.delegates` from `material_ui`.

## Out of scope

Router wiring and locale resolution.

## Done when

- [x] `docs/architecture.md` Tech stack matches the approved sentence
- [x] `flutter test` passes

## Result

The Tech stack localization sentence now says `MaterialApp` registers `AppLocalizations.localizationsDelegates` and `GlobalMaterialLocalizations.delegates` from `material_ui`. `flutter test` passed: 110 tests.
