import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/pages/categories/bloc/categories_bloc.dart';
import 'package:money_manager/pages/categories/bloc/categories_event.dart';
import 'package:money_manager/pages/categories/bloc/categories_state.dart';
import 'package:money_manager/pages/categories/categories_page.dart';
import 'package:money_manager/pages/categories/category_form_page.dart';
import 'package:money_manager/routes/app_routes.dart';

import '../support/memory_category_repository.dart';

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
    final bloc = await _loadedBloc([_food, _transit, _salary]);
    await _pumpPage(tester, bloc);

    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Transit'), findsOneWidget);
    expect(find.text('Salary'), findsNothing);

    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();

    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Food'), findsNothing);
  });

  testWidgets('reordering a category does not throw', (tester) async {
    final bloc = await _loadedBloc([_food, _transit, _salary]);
    await _pumpPage(tester, bloc);

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
    expect(
      bloc.state.categories
          .where((category) => category.kind == CategoryKind.expense)
          .map((category) => category.id),
      ['transit', 'food'],
    );
  });

  testWidgets('add uses the selected tab kind', (tester) async {
    final bloc = await _loadedBloc([_food, _salary]);
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
      BlocProvider.value(
        value: bloc,
        child: MaterialApp.router(
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
    final bloc = await _loadedBloc(const []);
    await _pumpForm(tester, bloc);

    for (final key in ['food', 'other', 'salary']) {
      expect(_iconSelected(tester, key), isFalse);
    }

    await tester.enterText(find.byType(TextField), 'Rent');
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Choose an icon'), findsOneWidget);

    await tester.tap(find.byTooltip('shopping'));
    await tester.pump();
    expect(_iconSelected(tester, 'shopping'), isTrue);
    expect(_iconSelected(tester, 'other'), isFalse);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final saved = bloc.state.categories.single;
    expect(saved.name, 'Rent');
    expect(saved.icon, 'shopping');
    expect(saved.languageEn, isNull);
    expect(saved.languageZh, isNull);
    expect(saved.languageZhCn, isNull);
  });

  testWidgets('editing a default category keeps one name', (tester) async {
    final bloc = await _loadedBloc([_localizedFood]);
    await _pumpForm(tester, bloc, categoryId: 'food');

    expect(_iconSelected(tester, 'food'), isTrue);
    expect(find.text('Food'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Groceries');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final saved = bloc.state.categories.single;
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

Future<CategoriesBloc> _loadedBloc(List<CategoryModel> categories) async {
  final repository = MemoryCategoryRepository()..categories.addAll(categories);
  final bloc = CategoriesBloc(repository)..add(const CategoriesStarted([]));
  await bloc.stream.firstWhere(
    (state) => state.status == CategoriesStatus.success,
  );
  return bloc;
}

Future<void> _pumpPage(WidgetTester tester, CategoriesBloc bloc) async {
  await tester.pumpWidget(
    BlocProvider.value(
      value: bloc,
      child: const MaterialApp(
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
  CategoriesBloc bloc, {
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
    BlocProvider.value(
      value: bloc,
      child: MaterialApp.router(
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
  return tester
          .widgetList<IconButton>(find.byType(IconButton))
          .firstWhere((button) => button.tooltip == key)
          .isSelected ==
      true;
}
