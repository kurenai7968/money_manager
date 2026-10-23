import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/repositories/category_repository.dart';

class MemoryCategoryRepository implements CategoryRepository {
  final List<CategoryModel> categories = [];

  @override
  Future<void> delete(String id) async {
    categories.removeWhere((category) => category.id == id);
  }

  @override
  Future<List<CategoryModel>> getAll() async {
    final copy = [...categories];
    copy.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return copy;
  }

  @override
  Future<bool> isEmpty() async => categories.isEmpty;

  @override
  Future<void> reorder(List<String> ids) async {
    for (var index = 0; index < ids.length; index++) {
      final categoryIndex = categories.indexWhere(
        (category) => category.id == ids[index],
      );
      categories[categoryIndex] = categories[categoryIndex].copyWith(
        sortOrder: index,
      );
    }
  }

  @override
  Future<void> save(CategoryModel category) async {
    categories.removeWhere((item) => item.id == category.id);
    categories.add(category);
  }
}
