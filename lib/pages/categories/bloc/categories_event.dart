import 'package:equatable/equatable.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';

sealed class CategoriesEvent extends Equatable {
  const CategoriesEvent();

  @override
  List<Object?> get props => [];
}

class CategoriesStarted extends CategoriesEvent {
  const CategoriesStarted(this.defaults);

  final List<CategoryModel> defaults;

  @override
  List<Object?> get props => [defaults];
}

class CategorySavePressed extends CategoriesEvent {
  const CategorySavePressed(this.category);

  final CategoryModel category;

  @override
  List<Object?> get props => [category];
}

class CategoryDeletePressed extends CategoriesEvent {
  const CategoryDeletePressed(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class CategoriesReorderPressed extends CategoriesEvent {
  const CategoriesReorderPressed(this.kind, this.ids);

  final CategoryKind kind;
  final List<String> ids;

  @override
  List<Object?> get props => [kind, ids];
}
