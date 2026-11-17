enum AccountBookColor { coral, red, blue, amber, teal, pink, green, slate }

enum AccountBookColorPair {
  redGreen(AccountBookColor.red, AccountBookColor.green),
  coralTeal(AccountBookColor.coral, AccountBookColor.teal),
  pinkBlue(AccountBookColor.pink, AccountBookColor.blue),
  amberSlate(AccountBookColor.amber, AccountBookColor.slate);

  final AccountBookColor expense;
  final AccountBookColor income;

  const AccountBookColorPair(this.expense, this.income);
}
