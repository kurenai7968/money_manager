import 'package:money_manager/core/errors/app_exception.dart';
import 'package:money_manager/core/mapping/account_mapping.dart';
import 'package:money_manager/core/utils/opening_transaction.dart';
import 'package:money_manager/database/sqlite/tables/account_table.dart';
import 'package:money_manager/database/sqlite/tables/transaction_table.dart';
import 'package:money_manager/database/sqlite/app_database.dart';
import 'package:money_manager/entities/account_entity.dart';
import 'package:money_manager/models/account_balances.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/account_book_kinds.dart';

abstract interface class AccountRepository {
  Future<List<AccountModel>> getAll();
  Future<AccountBalances> balances();
  Future<bool> isEmpty();
  Future<void> save(AccountModel account);
  Future<void> archive(String id);
  Future<void> reorder(List<String> ids);
}

class AccountRepositoryImpl implements AccountRepository {
  final AppDatabase _database;

  AccountRepositoryImpl({required this._database});

  @override
  Future<List<AccountModel>> getAll() {
    return guard('Accounts could not be read.', () async {
      final rows = await _database.query(
        AccountTable.tableName,
        orderBy: '${AccountTable.sortOrder} ASC, ${AccountTable.name} ASC',
      );
      return [
        for (final row in rows)
          AccountEntity.fromJson(Map<String, dynamic>.from(row)).toModel(),
      ];
    });
  }

  @override
  Future<AccountBalances> balances() {
    return guard('Accounts could not be read.', () async {
      final rows = await _database.rawQuery(_accountBalanceSql);
      final accounts = <AccountModel>[];
      final balanceById = <String, int>{};
      var netWorth = 0;
      for (final row in rows) {
        final json = Map<String, dynamic>.from(row);
        final balance = json.remove('balance_minor') as int;
        netWorth = json.remove('net_worth') as int;
        final account = AccountEntity.fromJson(json).toModel();
        accounts.add(account);
        balanceById[account.id] = balance;
      }
      return AccountBalances(
        accounts: accounts,
        balanceById: balanceById,
        netWorth: netWorth,
      );
    });
  }

  @override
  Future<bool> isEmpty() {
    return guard('Accounts could not be read.', () async {
      final count = await _database.count(
        'SELECT COUNT(*) FROM ${AccountTable.tableName}',
      );
      return count == 0;
    });
  }

  @override
  Future<void> save(AccountModel account) {
    return guard('Account could not be saved.', () async {
      await _database.insert(
        AccountTable.tableName,
        account.toEntity().toJson(),
      );
    });
  }

  @override
  Future<void> archive(String id) {
    return guard('Account could not be archived.', () async {
      await _database.update(
        AccountTable.tableName,
        {AccountTable.archived: 1},
        where: '${AccountTable.id} = ?',
        whereArgs: [id],
      );
    });
  }

  @override
  Future<void> reorder(List<String> ids) {
    return guard('Accounts could not be reordered.', () {
      return _database.transaction((txn) async {
        for (var index = 0; index < ids.length; index++) {
          await txn.update(
            AccountTable.tableName,
            {AccountTable.sortOrder: index},
            where: '${AccountTable.id} = ?',
            whereArgs: [ids[index]],
          );
        }
      });
    });
  }
}

String get _accountBalanceSql {
  const accounts = 'a';
  const transactions = 't';
  final accountId = '$accounts.${AccountTable.id}';
  final signed =
      '''
CASE
  WHEN $transactions.${TransactionTable.id} IS NULL THEN 0
  WHEN $transactions.${TransactionTable.id} = ('$openingTransactionPrefix' || $accountId)
    AND $transactions.${TransactionTable.accountId} = $accountId
    AND $transactions.${TransactionTable.type} IN ('${TransactionType.income.name}', '${TransactionType.expense.name}')
    THEN 0
  WHEN $transactions.${TransactionTable.type} = '${TransactionType.expense.name}'
    AND $transactions.${TransactionTable.accountId} = $accountId
    THEN -$transactions.${TransactionTable.amountMinor}
  WHEN $transactions.${TransactionTable.type} = '${TransactionType.income.name}'
    AND $transactions.${TransactionTable.accountId} = $accountId
    THEN $transactions.${TransactionTable.amountMinor}
  WHEN $transactions.${TransactionTable.type} = '${TransactionType.transfer.name}'
    AND $transactions.${TransactionTable.toAccountId} = $accountId
    AND $transactions.${TransactionTable.fromAccountId} = $accountId
    THEN 0
  WHEN $transactions.${TransactionTable.type} = '${TransactionType.transfer.name}'
    AND $transactions.${TransactionTable.toAccountId} = $accountId
    THEN $transactions.${TransactionTable.amountMinor}
  WHEN $transactions.${TransactionTable.type} = '${TransactionType.transfer.name}'
    AND $transactions.${TransactionTable.fromAccountId} = $accountId
    THEN -$transactions.${TransactionTable.amountMinor}
  ELSE 0
END''';
  final balance =
      '''
$accounts.${AccountTable.openingBalance} + COALESCE(SUM(
  CASE WHEN $accounts.${AccountTable.type} = '${AccountType.credit.name}' THEN -1 ELSE 1 END
  * ($signed)
), 0)''';
  return '''
WITH account_balance AS (
  SELECT
    $accountId AS ${AccountTable.id},
    $accounts.${AccountTable.name} AS ${AccountTable.name},
    $accounts.${AccountTable.languageEn} AS ${AccountTable.languageEn},
    $accounts.${AccountTable.languageZh} AS ${AccountTable.languageZh},
    $accounts.${AccountTable.languageZhCn} AS ${AccountTable.languageZhCn},
    $accounts.${AccountTable.type} AS ${AccountTable.type},
    $accounts.${AccountTable.openingBalance} AS ${AccountTable.openingBalance},
    $accounts.${AccountTable.sortOrder} AS ${AccountTable.sortOrder},
    $accounts.${AccountTable.archived} AS ${AccountTable.archived},
    $balance AS balance_minor
  FROM ${AccountTable.tableName} $accounts
  LEFT JOIN ${TransactionTable.tableName} $transactions
    ON $transactions.${TransactionTable.accountId} = $accountId
    OR $transactions.${TransactionTable.fromAccountId} = $accountId
    OR $transactions.${TransactionTable.toAccountId} = $accountId
  GROUP BY
    $accountId,
    $accounts.${AccountTable.name},
    $accounts.${AccountTable.languageEn},
    $accounts.${AccountTable.languageZh},
    $accounts.${AccountTable.languageZhCn},
    $accounts.${AccountTable.type},
    $accounts.${AccountTable.openingBalance},
    $accounts.${AccountTable.sortOrder},
    $accounts.${AccountTable.archived}
)
SELECT
  account_balance.*,
  SUM(
    CASE
      WHEN ${AccountTable.archived} = 0 AND ${AccountTable.type} = '${AccountType.credit.name}' THEN -balance_minor
      WHEN ${AccountTable.archived} = 0 THEN balance_minor
      ELSE 0
    END
  ) OVER () AS net_worth
FROM account_balance
ORDER BY ${AccountTable.sortOrder} ASC, ${AccountTable.name} ASC
''';
}
