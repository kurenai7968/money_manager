---
id: "00006"
status: done
reads:
  - docs/architecture.md
  - DESIGN.md
---

# Account history and transfer

## Outcome

An account page lists its transactions and can start a transfer with that account already chosen.

## Out of scope

Settings preferences and the analysis page.

## Done when

- [x] Account detail lists related transactions and opens a prefilled transfer
- [x] `flutter test` passes

## Result

Account detail shows the balance and its transactions. Transfer opens the record page with the type and source account filled in. `flutter test` passed.
