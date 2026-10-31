import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/pages/categories/categories_page.dart';
import 'package:money_manager/pages/categories/category_form_page.dart';
import 'package:money_manager/repositories/category_repository.dart';
import 'package:money_manager/repositories/transaction_repository.dart';
import 'package:money_manager/routes/app_routes.dart';
import 'package:money_manager/themes/ledger_palette.dart';

import '../support/memory_category_repository.dart';
import '../support/memory_transaction_repository.dart';

const _food = CategoryModel(
  id: 'food',
  name: 'Food',
  icon: 'food',
  color: 'coral',
  kind: CategoryKind.expense,
  sortOrder: 0,
);

const _transit = CategoryModel(
  id: 'transit',
  name: 'Transit',
  icon: 'transit',
  color: 'blue',
  kind: CategoryKind.expense,
  sortOrder: 1,
);

const _salary = CategoryModel(
  id: 'salary',
  name: 'Salary',
  icon: 'salary',
  color: 'green',
  kind: CategoryKind.income,
  sortOrder: 0,
);

const _localizedFood = CategoryModel(
  id: 'food',
  languageEn: 'Food',
  languageZh: '飲食',
  languageZhCn: '饮食',
  icon: 'food',
  color: 'coral',
  kind: CategoryKind.expense,
  sortOrder: 0,
);

void main() {
  testWidgets('expense and income use separate tabs', (tester) async {
    final categories = _repository([_food, _transit, _salary]);
    await _pumpPage(tester, categories);

    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Transit'), findsOneWidget);
    expect(find.text('Salary'), findsNothing);

    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();

    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Food'), findsNothing);
  });

  testWidgets('reordering a category does not throw', (tester) async {
    final categories = _repository([_food, _transit, _salary]);
    await _pumpPage(tester, categories);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byIcon(Icons.drag_handle).first),
      kind: PointerDeviceKind.mouse,
    );
    await gesture.moveBy(const Offset(0, 30));
    await tester.pump();
    await gesture.moveBy(const Offset(0, 80));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final saved = await categories.getAll();
    expect(
      saved
          .where((category) => category.kind == CategoryKind.expense)
          .map((category) => category.id),
      ['transit', 'food'],
    );
  });

  testWidgets('add uses the selected tab kind', (tester) async {
    final categories = _repository([_food, _salary]);
    final router = GoRouter(
      initialLocation: AppRoutes.categories.path,
      routes: [
        GoRoute(
          path: AppRoutes.categories.path,
          builder: (context, state) => const CategoriesPage(),
        ),
        GoRoute(
          path: AppRoutes.categoryNew.path,
          builder: (context, state) {
            final extra = state.extra;
            return CategoryFormPage(
              initialKind: extra is CategoryKind ? extra : CategoryKind.expense,
            );
          },
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      _provided(
        categories,
        MaterialApp.router(
          routerConfig: router,
          locale: const Locale('en'),
          localizationsDelegates: _delegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<SegmentedButton<CategoryKind>>(
            find.byType(SegmentedButton<CategoryKind>),
          )
          .selected,
      {CategoryKind.income},
    );
  });

  testWidgets('a new category starts with no icon selected', (tester) async {
    final categories = _repository(const []);
    await _pumpForm(tester, categories);

    for (final key in ['food', 'other', 'salary']) {
      expect(_iconSelected(tester, key), isFalse);
      expect(_iconFill(tester, key), Colors.transparent);
    }

    await tester.enterText(find.byType(TextField), 'Rent');
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Choose an icon'), findsOneWidget);

    await tester.tap(find.byTooltip('shopping'));
    await tester.pump();
    expect(_iconSelected(tester, 'shopping'), isTrue);
    expect(_iconFill(tester, 'shopping'), LedgerPalette.coral);
    expect(_iconFill(tester, 'other'), Colors.transparent);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final saved = (await categories.getAll()).singleWhere(
      (category) => category.name == 'Rent',
    );
    expect(saved.name, 'Rent');
    expect(saved.icon, 'shopping');
    expect(saved.languageEn, isNull);
    expect(saved.languageZh, isNull);
    expect(saved.languageZhCn, isNull);
  });

  testWidgets('editing a default category keeps one name', (tester) async {
    final categories = _repository([_localizedFood]);
    await _pumpForm(tester, categories, categoryId: 'food');

    expect(_iconSelected(tester, 'food'), isTrue);
    expect(find.text('Food'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Groceries');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final saved = (await categories.getAll()).single;
    expect(saved.name, 'Groceries');
    expect(saved.languageEn, isNull);
    expect(saved.languageZh, isNull);
    expect(saved.languageZhCn, isNull);
    expect(saved.labelFor('en'), 'Groceries');
    expect(saved.labelFor('zh'), 'Groceries');
    expect(saved.labelFor('zh_CN'), 'Groceries');
  });
}

const _delegates = [
  AppLocalizations.delegate,
  ...GlobalMaterialLocalizations.delegates,
];

MemoryCategoryRepository _repository(List<CategoryModel> categories) {
  return MemoryCategoryRepository()..categories.addAll(categories);
}

Widget _provided(MemoryCategoryRepository categories, Widget child) {
  return MultiRepositoryProvider(
    providers: [
      RepositoryProvider<CategoryRepository>.value(value: categories),
      RepositoryProvider<TransactionRepository>.value(
        value: MemoryTransactionRepository(),
      ),
    ],
    child: child,
  );
}

Future<void> _pumpPage(
  WidgetTester tester,
  MemoryCategoryRepository categories,
) async {
  await tester.pumpWidget(
    _provided(
      categories,
      const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: _delegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CategoriesPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpForm(
  WidgetTester tester,
  MemoryCategoryRepository categories, {
  String? categoryId,
}) async {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(body: SizedBox.shrink()),
      ),
      GoRoute(
        path: '/edit',
        builder: (context, state) => CategoryFormPage(categoryId: categoryId),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    _provided(
      categories,
      MaterialApp.router(
        routerConfig: router,
        locale: const Locale('en'),
        localizationsDelegates: _delegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  router.push('/edit');
  await tester.pumpAndSettle();
}

bool _iconSelected(WidgetTester tester, String key) {
  return _iconButton(tester, key).isSelected == true;
}

Color? _iconFill(WidgetTester tester, String key) {
  return _iconButton(
    tester,
    key,
  ).style?.backgroundColor?.resolve(const <WidgetState>{});
}

IconButton _iconButton(WidgetTester tester, String key) {
  return tester
      .widgetList<IconButton>(find.byType(IconButton))
      .firstWhere((button) => button.tooltip == key);
}
