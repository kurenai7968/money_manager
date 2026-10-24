import 'package:equatable/equatable.dart';
import 'package:money_manager/models/ledger_kinds.dart';

class AccountModel extends Equatable {
  const AccountModel({
    required this.id,
    this.name,
    this.languageEn,
    this.languageZh,
    this.languageZhCn,
    required this.type,
    required this.openingBalanceMinor,
    required this.sortOrder,
    this.archived = false,
  });

  final String id;
  final String? name;
  final String? languageEn;
  final String? languageZh;
  final String? languageZhCn;
  final AccountType type;
  final int openingBalanceMinor;
  final int sortOrder;
  final bool archived;

  String labelFor(String languageCode) {
    final localized = switch (languageCode) {
      'zh_CN' => languageZhCn,
      'zh' || 'zh_TW' || 'zh_HK' => languageZh,
      'en' => languageEn,
      _ => null,
    };
    final text = localized?.trim();
    if (text != null && text.isNotEmpty) {
      return text;
    }
    return name?.trim() ?? '';
  }

  bool get hasLabel {
    for (final value in [name, languageEn, languageZh, languageZhCn]) {
      if (value != null && value.trim().isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  AccountModel copyWith({
    String? id,
    String? name,
    String? languageEn,
    String? languageZh,
    String? languageZhCn,
    AccountType? type,
    int? openingBalanceMinor,
    int? sortOrder,
    bool? archived,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      languageEn: languageEn ?? this.languageEn,
      languageZh: languageZh ?? this.languageZh,
      languageZhCn: languageZhCn ?? this.languageZhCn,
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
    languageEn,
    languageZh,
    languageZhCn,
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
