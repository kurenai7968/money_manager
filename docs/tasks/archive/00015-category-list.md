---
id: "00015"
status: done
reads:
  - docs/architecture.md
  - lib/pages/categories/categories_page.dart
  - lib/pages/categories/category_form_page.dart
  - lib/pages/categories/bloc/categories_bloc.dart
  - lib/models/category_model.dart
  - lib/repositories/category_repository.dart
---

# Category list and default names

## Outcome

The category list shows expense and income on separate tabs, and dragging a category to a new position completes without an error. A new category starts with no icon selected, and saving asks for one when none is chosen. Saving an edit of a default category stores the entered name and clears the language fields, so a later language change keeps that name.

## Out of scope

Account language fields, the record page category grid, and new category kinds.

## Done when

- [x] Expense and income are separate tabs, and reordering a tab does not throw
- [x] A new category has no icon selected until the user chooses one
- [x] Saving an edited default category keeps one name across languages
- [x] `flutter test` passes

## Result

The category list shows expense and income on separate tabs. Each tab reorders on its own, and dragging a row completes without an error. A new category starts with no icon selected, and saving without one asks for an icon. Add opens the form on the selected tab's kind. Saving an edited default category stores the entered name and clears the language fields, so a later language change keeps that name. `flutter test` passed.
