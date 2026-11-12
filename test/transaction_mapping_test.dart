import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/core/mapping/transaction_mapping.dart';
import 'package:money_manager/entities/transaction_entity.dart';
import 'package:money_manager/models/account_book_kinds.dart';

void main() {
  test('reads a stored income row', () {
    final model = const TransactionEntity(
      id: 1,
      type: 'income',
      amount: 15.0,
      date: '2026-10-01',
      accountId: 2,
    ).toModel();

    expect(model.type, TransactionType.income);
    expect(model.amount, 15);
    expect(model.accountId, 2);
  });
}
