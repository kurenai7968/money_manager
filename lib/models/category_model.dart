import 'package:equatable/equatable.dart';
import 'package:money_manager/models/ledger_kinds.dart';

class CategoryModel extends Equatable {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.kind,
    required this.sortOrder,
    this.archived = false,
  });

  final String id;
  final String name;
  final String icon;
  final String color;
  final CategoryKind kind;
  final int sortOrder;
  final bool archived;

  CategoryModel copyWith({
    String? id,
    String? name,
    String? icon,
    String? color,
    CategoryKind? kind,
    int? sortOrder,
    bool? archived,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      kind: kind ?? this.kind,
      sortOrder: sortOrder ?? this.sortOrder,
      archived: archived ?? this.archived,
    );
  }

  @override
  List<Object?> get props => [id, name, icon, color, kind, sortOrder, archived];
}
