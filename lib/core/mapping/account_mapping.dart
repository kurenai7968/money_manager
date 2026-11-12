import 'package:money_manager/entities/account_entity.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/account_book_kinds.dart';

extension AccountEntityMapping on AccountEntity {
  AccountModel toModel() {
    return AccountModel(
      id: id,
      name: name,
      languageEn: languageEn,
      languageZh: languageZh,
      languageZhCn: languageZhCn,
      type: AccountType.values.byName(type),
      icon: icon,
      sortOrder: sortOrder,
      isActive: isActive,
    );
  }
}

extension AccountModelMapping on AccountModel {
  AccountEntity toEntity() {
    return AccountEntity(
      id: id,
      name: name,
      languageEn: languageEn,
      languageZh: languageZh,
      languageZhCn: languageZhCn,
      type: type.name,
      icon: icon,
      sortOrder: sortOrder,
      isActive: isActive,
    );
  }
}
