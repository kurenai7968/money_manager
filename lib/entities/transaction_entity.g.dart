// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionEntity _$TransactionEntityFromJson(Map<String, dynamic> json) =>
    TransactionEntity(
      id: json['id'] as String,
      type: json['type'] as String,
      amountMinor: (json['amount_minor'] as num).toInt(),
      date: json['date'] as String,
      note: json['note'] as String?,
      accountId: json['account_id'] as String?,
      categoryId: json['category_id'] as String?,
      fromAccountId: json['from_account_id'] as String?,
      toAccountId: json['to_account_id'] as String?,
    );

Map<String, dynamic> _$TransactionEntityToJson(TransactionEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'amount_minor': instance.amountMinor,
      'date': instance.date,
      'note': instance.note,
      'account_id': instance.accountId,
      'category_id': instance.categoryId,
      'from_account_id': instance.fromAccountId,
      'to_account_id': instance.toAccountId,
    };
