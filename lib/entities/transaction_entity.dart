import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'transaction_entity.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TransactionEntity extends Equatable {
  @JsonKey(includeIfNull: false)
  final int? id;
  final String type;
  final double amount;
  final String date;
  final String? note;
  final int? accountId;
  final int? categoryId;
  final int? fromAccountId;
  final int? toAccountId;

  const TransactionEntity({
    this.id,
    required this.type,
    required this.amount,
    required this.date,
    this.note,
    this.accountId,
    this.categoryId,
    this.fromAccountId,
    this.toAccountId,
  });

  factory TransactionEntity.fromJson(Map<String, dynamic> json) =>
      _$TransactionEntityFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionEntityToJson(this);

  @override
  List<Object?> get props => [
    id,
    type,
    amount,
    date,
    note,
    accountId,
    categoryId,
    fromAccountId,
    toAccountId,
  ];
}
