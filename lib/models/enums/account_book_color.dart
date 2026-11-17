enum LedgerColor { coral, red, blue, amber, teal, pink, green, slate }

enum LedgerColorPair {
  redGreen(LedgerColor.red, LedgerColor.green),
  coralTeal(LedgerColor.coral, LedgerColor.teal),
  pinkBlue(LedgerColor.pink, LedgerColor.blue),
  amberSlate(LedgerColor.amber, LedgerColor.slate);

  final LedgerColor expense;
  final LedgerColor income;

  const LedgerColorPair(this.expense, this.income);
}
