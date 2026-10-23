import 'package:equatable/equatable.dart';
import 'package:money_manager/models/category_model.dart';

enum CategoriesStatus { initial, loading, success, failure }

enum CategoriesError { none, saveFailed, nameRequired }

class CategoriesState extends Equatable {
  const CategoriesState({
    this.status = CategoriesStatus.initial,
    this.categories = const [],
    this.error = CategoriesError.none,
  });

  final CategoriesStatus status;
  final List<CategoryModel> categories;
  final CategoriesError error;

  List<CategoryModel> get active =>
      categories.where((category) => !category.archived).toList();

  CategoriesState copyWith({
    CategoriesStatus? status,
    List<CategoryModel>? categories,
    CategoriesError? error,
  }) {
    return CategoriesState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, categories, error];
}
