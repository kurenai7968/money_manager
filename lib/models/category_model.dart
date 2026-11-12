import 'package:equatable/equatable.dart';
import 'package:money_manager/models/account_book_kinds.dart';

class CategoryModel extends Equatable {
  final int? id;
  final String? name;
  final String? languageEn;
  final String? languageZh;
  final String? languageZhCn;
  final String icon;
  final CategoryKind type;
  final int sortOrder;
  final bool isActive;

  const CategoryModel({
    this.id,
    this.name,
    this.languageEn,
    this.languageZh,
    this.languageZhCn,
    required this.icon,
    required this.type,
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

  CategoryModel copyWith({
    int? id,
    String? name,
    String? languageEn,
    String? languageZh,
    String? languageZhCn,
    String? icon,
    CategoryKind? type,
    int? sortOrder,
    bool? isActive,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      languageEn: languageEn ?? this.languageEn,
      languageZh: languageZh ?? this.languageZh,
      languageZhCn: languageZhCn ?? this.languageZhCn,
      icon: icon ?? this.icon,
      type: type ?? this.type,
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
    icon,
    type,
    sortOrder,
    isActive,
  ];
}
