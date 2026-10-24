import 'package:equatable/equatable.dart';
import 'package:money_manager/models/ledger_kinds.dart';

class CategoryModel extends Equatable {
  const CategoryModel({
    required this.id,
    this.name,
    this.languageEn,
    this.languageZh,
    this.languageZhCn,
    required this.icon,
    required this.color,
    required this.kind,
    required this.sortOrder,
    this.archived = false,
  });

  final String id;
  final String? name;
  final String? languageEn;
  final String? languageZh;
  final String? languageZhCn;
  final String icon;
  final String color;
  final CategoryKind kind;
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

  CategoryModel copyWith({
    String? id,
    String? name,
    String? languageEn,
    String? languageZh,
    String? languageZhCn,
    String? icon,
    String? color,
    CategoryKind? kind,
    int? sortOrder,
    bool? archived,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      languageEn: languageEn ?? this.languageEn,
      languageZh: languageZh ?? this.languageZh,
      languageZhCn: languageZhCn ?? this.languageZhCn,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      kind: kind ?? this.kind,
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
    icon,
    color,
    kind,
    sortOrder,
    archived,
  ];
}
