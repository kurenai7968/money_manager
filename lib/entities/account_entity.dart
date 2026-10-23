import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:money_manager/core/utils/bool_int_converter.dart';

part 'account_entity.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AccountEntity extends Equatable {
  const AccountEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.openingBalance,
    required this.sortOrder,
    required this.archived,
  });

  factory AccountEntity.fromJson(Map<String, dynamic> json) =>
      _$AccountEntityFromJson(json);

  final String id;
  final String name;
  final String type;
  final int openingBalance;
  final int sortOrder;

  @BoolIntConverter()
  final bool archived;

  Map<String, dynamic> toJson() => _$AccountEntityToJson(this);

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    openingBalance,
    sortOrder,
    archived,
  ];
}
