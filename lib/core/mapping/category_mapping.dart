import 'package:money_manager/entities/category_entity.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/account_book_kinds.dart';

extension CategoryEntityMapping on CategoryEntity {
  CategoryModel toModel() {
    return CategoryModel(
      id: id,
      name: name,
      languageEn: languageEn,
      languageZh: languageZh,
      languageZhCn: languageZhCn,
      icon: icon,
      type: CategoryKind.values.byName(type),
      sortOrder: sortOrder,
      isActive: isActive,
    );
  }
}

extension CategoryModelMapping on CategoryModel {
  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      languageEn: languageEn,
      languageZh: languageZh,
      languageZhCn: languageZhCn,
      icon: icon,
      type: type.name,
      sortOrder: sortOrder,
      isActive: isActive,
    );
  }
}
