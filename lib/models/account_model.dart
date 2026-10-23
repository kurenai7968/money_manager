import 'package:equatable/equatable.dart';
import 'package:money_manager/models/ledger_kinds.dart';

class AccountModel extends Equatable {
  const AccountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.openingBalanceMinor,
    required this.sortOrder,
    this.archived = false,
  });

  final String id;
  final String name;
  final AccountType type;
  final int openingBalanceMinor;
  final int sortOrder;
  final bool archived;

  AccountModel copyWith({
    String? id,
    String? name,
    AccountType? type,
    int? openingBalanceMinor,
    int? sortOrder,
    bool? archived,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      openingBalanceMinor: openingBalanceMinor ?? this.openingBalanceMinor,
      sortOrder: sortOrder ?? this.sortOrder,
      archived: archived ?? this.archived,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    openingBalanceMinor,
    sortOrder,
    archived,
  ];
}

int netWorthMinor(Iterable<AccountModel> accounts) {
  var total = 0;
  for (final account in accounts.where((item) => !item.archived)) {
    if (account.type == AccountType.credit) {
      total -= account.openingBalanceMinor;
    } else {
      total += account.openingBalanceMinor;
    }
  }
  return total;
}
