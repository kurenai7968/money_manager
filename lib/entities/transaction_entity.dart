import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'transaction_entity.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TransactionEntity extends Equatable {
  const TransactionEntity({
    required this.id,
    required this.type,
    required this.amountMinor,
    required this.date,
    this.note,
    this.accountId,
    this.categoryId,
    this.fromAccountId,
    this.toAccountId,
  });

  factory TransactionEntity.fromJson(Map<String, dynamic> json) =>
      _$TransactionEntityFromJson(json);

  final String id;
  final String type;
  final int amountMinor;
  final String date;
  final String? note;
  final String? accountId;
  final String? categoryId;
  final String? fromAccountId;
  final String? toAccountId;

  Map<String, dynamic> toJson() => _$TransactionEntityToJson(this);

  @override
  List<Object?> get props => [
    id,
    type,
    amountMinor,
    date,
    note,
    accountId,
    categoryId,
    fromAccountId,
    toAccountId,
  ];
}
