import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/app.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:money_manager/themes/ledger_palette.dart';
import 'package:money_manager/widgets/app_tab_bar.dart';
import 'package:money_manager/widgets/transaction_item.dart';

import '../support/memory_account_repository.dart';
import '../support/memory_app_setting_repository.dart';
import '../support/memory_category_repository.dart';
import '../support/memory_transaction_repository.dart';

const _delegates = [
  AppLocalizations.delegate,
  ...GlobalMaterialLocalizations.delegates,
];

const _food = CategoryModel(
  id: 'food',
  name: 'Food',
  icon: 'food',
  color: 'coral',
  kind: CategoryKind.expense,
  sortOrder: 0,
);

const _cash = AccountModel(
  id: 'cash',
  name: 'Cash',
  type: AccountType.cash,
  openingBalanceMinor: 0,
  sortOrder: 0,
);

const _card = AccountModel(
  id: 'card',
  name: 'Card',
  type: AccountType.credit,
  openingBalanceMinor: 0,
  sortOrder: 1,
);

void main() {
  testWidgets('row shows category, note, amount, and account', (tester) async {
    await _pumpItem(
      tester,
      transaction: TransactionModel(
        id: 'lunch',
        type: TransactionType.expense,
        amountMinor: 8800,
        date: DateTime(2026, 10, 30),
        note: 'Lunch #work',
        accountId: _cash.id,
        categoryId: _food.id,
      ),
      categories: const [_food],
      accounts: const [_cash],
    );

    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Lunch #work'), findsOneWidget);
    expect(find.text('-88'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);
    expect(find.byIcon(Icons.restaurant_outlined), findsOneWidget);
    expect(_noteTagColor(tester), LedgerPalette.green);
    expect(
      tester.widget<Text>(find.text('-88')).style?.color,
      LedgerPalette.coral,
    );
    expect(tester.widget<InkWell>(find.byType(InkWell)).onTap, isNotNull);
  });

  testWidgets('transfer names both accounts and stays near-black', (
    tester,
  ) async {
    await _pumpItem(
      tester,
      transaction: TransactionModel(
        id: 'move',
        type: TransactionType.transfer,
        amountMinor: 2000,
        date: DateTime(2026, 10, 30),
        fromAccountId: 'cash',
        toAccountId: 'card',
      ),
      categories: const [],
      accounts: const [_cash, _card],
      theme: AppThemes.dark,
    );

    expect(find.text('Transfer'), findsOneWidget);
    expect(find.text('Cash → Card'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);
    expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('20')).style?.color,
      AppThemes.dark.colorScheme.onSurface,
    );
  });

  testWidgets('opening balance is labeled and not editable', (tester) async {
    await _pumpItem(
      tester,
      transaction: TransactionModel(
        id: 'opening-cash',
        type: TransactionType.opening,
        amountMinor: 5000,
        date: DateTime(2026, 10, 30),
        accountId: _cash.id,
      ),
      categories: const [],
      accounts: const [_cash],
    );

    expect(find.text('Opening balance'), findsOneWidget);
    expect(find.text('50'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);
    expect(tester.widget<InkWell>(find.byType(InkWell)).onTap, isNull);
  });

  testWidgets('day header shows the date and that day expense', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: _delegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppThemes.light,
        home: Scaffold(
          body: TransactionList(
            transactions: [
              TransactionModel(
                id: 'lunch',
                type: TransactionType.expense,
                amountMinor: 8800,
                date: DateTime(2026, 10, 30),
                categoryId: _food.id,
                accountId: _cash.id,
              ),
              TransactionModel(
                id: 'pay',
                type: TransactionType.income,
                amountMinor: 100,
                date: DateTime(2026, 10, 29),
                accountId: 'cash',
              ),
            ],
            categories: const [_food],
            accounts: const [_cash],
            locale: 'en',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(DateFormat('M/d (E)', 'en').format(DateTime(2026, 10, 30))),
      findsOneWidget,
    );
    expect(find.text('Expense 88'), findsOneWidget);
    expect(
      find.text(DateFormat('M/d (E)', 'en').format(DateTime(2026, 10, 29))),
      findsOneWidget,
    );
    expect(find.text('Expense 1'), findsNothing);
  });

  testWidgets('a long row fits a narrow screen at larger text', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _pumpItem(
      tester,
      transaction: TransactionModel(
        id: 'lunch',
        type: TransactionType.expense,
        amountMinor: 123456,
        date: DateTime(2026, 10, 30),
        note: 'A very long note that should stay on one line',
        accountId: _cash.id,
        categoryId: _food.id,
      ),
      categories: const [
        CategoryModel(
          id: 'food',
          name: 'A very long category name',
          icon: 'food',
          color: 'coral',
          kind: CategoryKind.expense,
          sortOrder: 0,
        ),
      ],
      accounts: const [
        AccountModel(
          id: 'cash',
          name: 'A very long account name',
          type: AccountType.cash,
          openingBalanceMinor: 0,
          sortOrder: 0,
        ),
      ],
      textScale: 1.3,
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('home and account history use the same row', (tester) async {
    tester.platformDispatcher.localeTestValue = const Locale('en');
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    final now = DateTime.now();
    final accounts = MemoryAccountRepository()
      ..accounts.add(
        const AccountModel(
          id: 'cash',
          name: 'Wallet',
          type: AccountType.cash,
          openingBalanceMinor: 0,
          sortOrder: 0,
        ),
      );
    final categories = MemoryCategoryRepository()..categories.add(_food);
    final transactions = MemoryTransactionRepository()
      ..transactions.add(
        TransactionModel(
          id: 'lunch',
          type: TransactionType.expense,
          amountMinor: 8800,
          date: DateTime(now.year, now.month, now.day),
          note: 'Lunch #work',
          accountId: 'cash',
          categoryId: _food.id,
        ),
      );

    await tester.pumpWidget(
      App(
        accounts: accounts,
        categories: categories,
        transactions: transactions,
        settings: MemoryAppSettingRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(_rowText('Food'), findsOneWidget);
    expect(_rowText('Lunch #work'), findsOneWidget);
    expect(_rowText('-88'), findsOneWidget);
    expect(_rowText('Wallet'), findsOneWidget);
    expect(find.text(DateFormat('M/d (E)', 'en').format(now)), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(AppTabBar),
        matching: find.text('Accounts'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wallet'));
    await tester.pumpAndSettle();

    expect(_rowText('Food'), findsOneWidget);
    expect(_rowText('Lunch #work'), findsOneWidget);
    expect(_rowText('-88'), findsOneWidget);
    expect(_rowText('Wallet'), findsOneWidget);
    expect(find.byType(TransactionItem), findsOneWidget);
  });
}

Future<void> _pumpItem(
  WidgetTester tester, {
  required TransactionModel transaction,
  required List<CategoryModel> categories,
  required List<AccountModel> accounts,
  ThemeData? theme,
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: _delegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: theme ?? AppThemes.light,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        );
      },
      home: Scaffold(
        body: TransactionItem(
          transaction: transaction,
          categories: categories,
          accounts: accounts,
          locale: 'en',
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _rowText(String text) {
  return find.descendant(
    of: find.byType(TransactionItem),
    matching: find.text(text),
  );
}

Color? _noteTagColor(WidgetTester tester) {
  final note = tester.widget<RichText>(
    find.byWidgetPredicate((widget) {
      return widget is RichText && widget.text.toPlainText() == 'Lunch #work';
    }),
  );
  Color? tag;
  note.text.visitChildren((span) {
    if (span is TextSpan && span.text != null && span.text!.startsWith('#')) {
      tag = span.style?.color;
    }
    return true;
  });
  return tag;
}
