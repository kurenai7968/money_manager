import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/app.dart';
import 'package:money_manager/database/sqlite/app_database.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/repositories/account_repository.dart';
import 'package:money_manager/repositories/category_repository.dart';
import 'package:money_manager/repositories/transaction_repository.dart';

import 'test_stores.dart';

void useAppTestBinding() {
  LiveTestWidgetsFlutterBinding.ensureInitialized();
}

Future<void> pumpApp(
  WidgetTester tester, {
  List<AccountModel> accounts = const [],
  List<CategoryModel> categories = const [],
  List<TransactionModel> transactions = const [],
}) async {
  await openTestPreferences();
  await openTestDatabase();
  final database = AppDatabase.instance;
  final accountRepository = AccountRepositoryImpl(database: database);
  final categoryRepository = CategoryRepositoryImpl(database: database);
  final transactionRepository = TransactionRepositoryImpl(database: database);
  for (final account in accounts) {
    await accountRepository.save(account);
  }
  for (final category in categories) {
    await categoryRepository.save(category);
  }
  for (final transaction in transactions) {
    await transactionRepository.save(transaction);
  }
  await tester.pumpWidget(const App());
}

Future<List<AccountModel>> loadAccounts() {
  return AccountRepositoryImpl(database: AppDatabase.instance).getAll();
}
