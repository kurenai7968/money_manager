import 'package:equatable/equatable.dart';
import 'package:money_manager/models/account_book_kinds.dart';

class AccountModel extends Equatable {
  final int? id;
  final String? name;
  final String? languageEn;
  final String? languageZh;
  final String? languageZhCn;
  final AccountType type;
  final String icon;
  final int sortOrder;
  final bool isActive;

  const AccountModel({
    this.id,
    this.name,
    this.languageEn,
    this.languageZh,
    this.languageZhCn,
    required this.type,
    required this.icon,
    required this.sortOrder,
    this.isActive = true,
  });

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
    int? id,
    String? name,
    String? languageEn,
    String? languageZh,
    String? languageZhCn,
    AccountType? type,
    String? icon,
    int? sortOrder,
    bool? isActive,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      languageEn: languageEn ?? this.languageEn,
      languageZh: languageZh ?? this.languageZh,
      languageZhCn: languageZhCn ?? this.languageZhCn,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
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
    icon,
    sortOrder,
    isActive,
  ];
}
