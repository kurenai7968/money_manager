import 'package:equatable/equatable.dart';
import 'package:money_manager/models/account_book_kinds.dart';

enum AccountFormStatus { initial, success, failure }

enum AccountFormError { none, nameRequired, archiveBlocked }

class AccountFormState extends Equatable {
  final AccountFormStatus status;
  final AccountFormError error;
  final int? accountId;
  final bool prepared;
  final bool editing;
  final bool saved;
  final AccountType type;
  final String icon;
  final int sortOrder;
  final bool isActive;
  final String name;
  final bool localized;

  const AccountFormState({
    this.accountId,
    this.status = AccountFormStatus.initial,
    this.error = AccountFormError.none,
    this.prepared = false,
    this.editing = false,
    this.saved = false,
    this.type = AccountType.cash,
    this.icon = 'other',
    this.sortOrder = 0,
    this.isActive = true,
    this.name = '',
    this.localized = false,
  });

  AccountFormState copyWith({
    AccountFormStatus? status,
    AccountFormError? error,
    int? accountId,
    bool? prepared,
    bool? editing,
    bool? saved,
    AccountType? type,
    String? icon,
    int? sortOrder,
    bool? isActive,
    String? name,
    bool? localized,
  }) {
    return AccountFormState(
      status: status ?? this.status,
      error: error ?? this.error,
      accountId: accountId ?? this.accountId,
      prepared: prepared ?? this.prepared,
      editing: editing ?? this.editing,
      saved: saved ?? this.saved,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      name: name ?? this.name,
      localized: localized ?? this.localized,
    );
  }

  @override
  List<Object?> get props => [
    status,
    error,
    accountId,
    prepared,
    editing,
    saved,
    type,
    icon,
    sortOrder,
    isActive,
    name,
    localized,
  ];
}
