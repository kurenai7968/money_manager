import 'package:money_manager/entities/account_entity.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';

extension AccountEntityMapping on AccountEntity {
  AccountModel toModel() {
    return AccountModel(
      id: id,
      name: name,
      type: AccountType.values.byName(type),
      openingBalanceMinor: openingBalance,
      sortOrder: sortOrder,
      archived: archived,
    );
  }
}

extension AccountModelMapping on AccountModel {
  AccountEntity toEntity() {
    return AccountEntity(
      id: id,
      name: name,
      type: type.name,
      openingBalance: openingBalanceMinor,
      sortOrder: sortOrder,
      archived: archived,
    );
  }
}
