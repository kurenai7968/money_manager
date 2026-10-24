import 'package:money_manager/entities/category_entity.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';

extension CategoryEntityMapping on CategoryEntity {
  CategoryModel toModel() {
    return CategoryModel(
      id: id,
      name: name,
      languageEn: languageEn,
      languageZh: languageZh,
      languageZhCn: languageZhCn,
      icon: icon,
      color: color,
      kind: CategoryKind.values.byName(kind),
      sortOrder: sortOrder,
      archived: archived,
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
      color: color,
      kind: kind.name,
      sortOrder: sortOrder,
      archived: archived,
    );
  }
}
