import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/core/mapping/transaction_mapping.dart';
import 'package:money_manager/entities/transaction_entity.dart';
import 'package:money_manager/models/ledger_kinds.dart';

void main() {
  test('reads a stored opening row as income', () {
    final model = const TransactionEntity(
      id: 'opening-cash',
      type: 'opening',
      amountMinor: 1500,
      date: '2026-10-01',
      accountId: 'cash',
    ).toModel();

    expect(model.type, TransactionType.income);
    expect(model.amountMinor, 1500);
    expect(model.accountId, 'cash');
  });
}
