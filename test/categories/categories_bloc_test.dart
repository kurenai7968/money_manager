import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/pages/categories/bloc/categories_bloc.dart';
import 'package:money_manager/pages/categories/bloc/categories_event.dart';
import 'package:money_manager/pages/categories/bloc/categories_state.dart';

import '../support/memory_category_repository.dart';

void main() {
  late MemoryCategoryRepository repository;

  setUp(() {
    repository = MemoryCategoryRepository();
  });

  const food = CategoryModel(
    id: 'food',
    name: 'Food',
    icon: 'food',
    color: 'coral',
    kind: CategoryKind.expense,
    sortOrder: 0,
  );

  blocTest<CategoriesBloc, CategoriesState>(
    'seeds defaults when the store is empty',
    build: () => CategoriesBloc(repository),
    act: (bloc) => bloc.add(const CategoriesStarted([food])),
    verify: (bloc) {
      expect(bloc.state.categories, [food]);
    },
  );

  blocTest<CategoriesBloc, CategoriesState>(
    'does not seed again when categories exist',
    build: () => CategoriesBloc(repository),
    setUp: () {
      repository.categories.add(food);
    },
    act: (bloc) => bloc.add(
      const CategoriesStarted([
        CategoryModel(
          id: 'other',
          name: 'Other',
          icon: 'other',
          color: 'slate',
          kind: CategoryKind.expense,
          sortOrder: 1,
        ),
      ]),
    ),
    verify: (bloc) {
      expect(bloc.state.categories.map((category) => category.id), ['food']);
    },
  );

  blocTest<CategoriesBloc, CategoriesState>(
    'saves a category that only has language names',
    build: () => CategoriesBloc(repository),
    act: (bloc) => bloc.add(
      const CategorySavePressed(
        CategoryModel(
          id: 'food',
          languageEn: 'Food',
          languageZh: '飲食',
          languageZhCn: '饮食',
          icon: 'food',
          color: 'coral',
          kind: CategoryKind.expense,
          sortOrder: 0,
        ),
      ),
    ),
    verify: (bloc) {
      expect(bloc.state.categories.single.name, isNull);
      expect(bloc.state.categories.single.languageZh, '飲食');
    },
  );

  blocTest<CategoriesBloc, CategoriesState>(
    'rejects an empty name',
    build: () => CategoriesBloc(repository),
    seed: () => const CategoriesState(status: CategoriesStatus.success),
    act: (bloc) => bloc.add(
      const CategorySavePressed(
        CategoryModel(
          id: 'blank',
          name: ' ',
          icon: 'other',
          color: 'slate',
          kind: CategoryKind.expense,
          sortOrder: 0,
        ),
      ),
    ),
    expect: () => const [
      CategoriesState(
        status: CategoriesStatus.failure,
        error: CategoriesError.nameRequired,
      ),
    ],
  );

  blocTest<CategoriesBloc, CategoriesState>(
    'deletes a category',
    build: () => CategoriesBloc(repository),
    setUp: () {
      repository.categories.add(food);
    },
    act: (bloc) => bloc.add(const CategoryDeletePressed('food')),
    verify: (bloc) {
      expect(bloc.state.categories, isEmpty);
    },
  );
}
