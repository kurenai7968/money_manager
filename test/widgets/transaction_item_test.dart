import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/account_book_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:money_manager/themes/account_book_palette.dart';
import 'package:money_manager/widgets/app_tab_bar.dart';
import 'package:money_manager/widgets/transaction_item.dart';

import '../support/pump_app.dart';

const _delegates = [
  AppLocalizations.delegate,
  ...GlobalMaterialLocalizations.delegates,
];

const _food = CategoryModel(
  id: 1,
  name: 'Food',
  icon: 'food',
  type: CategoryKind.expense,
  sortOrder: 0,
);

const _cash = AccountModel(
  id: 2,
  name: 'Cash',
  type: AccountType.cash,
  icon: 'other',
  sortOrder: 0,
);

const _card = AccountModel(
  id: 3,
  name: 'Card',
  type: AccountType.credit,
  icon: 'other',
  sortOrder: 1,
);

void main() {
  useAppTestBinding();

  testWidgets('row shows category, note, amount, and account', (tester) async {
    await _pumpItem(
      tester,
      transaction: TransactionModel(
        id: 4,
        type: TransactionType.expense,
        amount: 88.0,
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
    expect(_noteTagColor(tester), AccountBookPalette.green);
    expect(
      tester.widget<Text>(find.text('-88')).style?.color,
      AccountBookPalette.coral,
    );
    expect(tester.widget<InkWell>(find.byType(InkWell)).onTap, isNotNull);
  });

  testWidgets('transfer names both accounts and stays near-black', (
    tester,
  ) async {
    await _pumpItem(
      tester,
      transaction: TransactionModel(
        id: 5,
        type: TransactionType.transfer,
        amount: 20.0,
        date: DateTime(2026, 10, 30),
        fromAccountId: 2,
        toAccountId: 3,
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

  testWidgets('opening balance opens the record page as income', (
    tester,
  ) async {
    await _pumpItem(
      tester,
      transaction: TransactionModel(
        id: 6,
        type: TransactionType.income,
        amount: 50.0,
        date: DateTime(2026, 10, 30),
        accountId: _cash.id,
      ),
      categories: const [],
      accounts: const [_cash],
    );

    expect(find.text('Income'), findsOneWidget);
    expect(find.text('+50'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);
    expect(tester.widget<InkWell>(find.byType(InkWell)).onTap, isNotNull);
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
                id: 4,
                type: TransactionType.expense,
                amount: 88.0,
                date: DateTime(2026, 10, 30),
                categoryId: _food.id,
                accountId: _cash.id,
              ),
              TransactionModel(
                id: 7,
                type: TransactionType.income,
                amount: 1.0,
                date: DateTime(2026, 10, 29),
                accountId: 2,
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
        id: 4,
        type: TransactionType.expense,
        amount: 1234.56,
        date: DateTime(2026, 10, 30),
        note: 'A very long note that should stay on one line',
        accountId: _cash.id,
        categoryId: _food.id,
      ),
      categories: const [
        CategoryModel(
          id: 1,
          name: 'A very long category name',
          icon: 'food',
          type: CategoryKind.expense,
          sortOrder: 0,
        ),
      ],
      accounts: const [
        AccountModel(
          id: 2,
          name: 'A very long account name',
          type: AccountType.cash,
          icon: 'other',
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
    await pumpApp(
      tester,
      accounts: const [
        AccountModel(
          id: 2,
          name: 'Wallet',
          type: AccountType.cash,
          icon: 'other',
          sortOrder: 0,
        ),
      ],
      categories: const [_food],
      transactions: [
        TransactionModel(
          id: 4,
          type: TransactionType.expense,
          amount: 88.0,
          date: DateTime(now.year, now.month, now.day),
          note: 'Lunch #work',
          accountId: 2,
          categoryId: _food.id,
        ),
      ],
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
