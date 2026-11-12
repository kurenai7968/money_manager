import 'package:equatable/equatable.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/account_book_kinds.dart';

sealed class CategoriesEvent extends Equatable {
  const CategoriesEvent();

  @override
  List<Object?> get props => [];
}

class CategoriesInitialized extends CategoriesEvent {
  final List<CategoryModel> defaults;

  const CategoriesInitialized(this.defaults);

  @override
  List<Object?> get props => [defaults];
}

class CategorySavePressed extends CategoriesEvent {
  final CategoryModel category;

  const CategorySavePressed(this.category);

  @override
  List<Object?> get props => [category];
}

class CategoryDeletePressed extends CategoriesEvent {
  final int id;

  const CategoryDeletePressed(this.id);

  @override
  List<Object?> get props => [id];
}

class CategoriesReorderPressed extends CategoriesEvent {
  final CategoryKind kind;
  final List<int> ids;

  const CategoriesReorderPressed(this.kind, this.ids);

  @override
  List<Object?> get props => [kind, ids];
}
