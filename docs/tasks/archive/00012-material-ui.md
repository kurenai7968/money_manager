---
id: "00012"
status: done
reads:
  - docs/architecture.md
  - pubspec.yaml
  - lib/app.dart
  - l10n.yaml
---

# Migrate to material_ui

## Outcome

Material widgets, icons, themes, and `MaterialApp` come from `package:material_ui/material_ui.dart`. Application and test code no longer imports `package:flutter/material.dart`. `MaterialApp` registers `AppLocalizations.delegate` together with `GlobalMaterialLocalizations.delegates` from `material_ui`.

## Out of scope

Visual redesign, navigation, ledger behavior, and a direct `cupertino_ui` dependency. Generated ARB output stays produced by `flutter gen-l10n`.

## Done when

- [x] `material_ui` is a direct dependency
- [x] `lib/` and `test/` do not import `package:flutter/material.dart`
- [x] `MaterialApp` uses `material_ui` localization delegates
- [x] `flutter test` passes

## Result

`material_ui` 1.8.0 is a direct dependency. Sixteen Dart files in `lib/` and `test/` import `package:material_ui/material_ui.dart`. `MaterialApp` registers `AppLocalizations.delegate` and `GlobalMaterialLocalizations.delegates` from `material_ui`. `flutter test` passed.
