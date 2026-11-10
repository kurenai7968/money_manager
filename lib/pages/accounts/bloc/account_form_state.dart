import 'package:equatable/equatable.dart';
import 'package:money_manager/models/account_book_kinds.dart';

enum AccountFormStatus { initial, success, failure }

enum AccountFormError { none, nameRequired, amountInvalid, archiveBlocked }

class AccountFormState extends Equatable {
  final AccountFormStatus status;
  final AccountFormError error;
  final String accountId;
  final bool prepared;
  final bool editing;
  final bool saved;
  final AccountType type;
  final int sortOrder;
  final bool archived;
  final String name;
  final String balanceText;
  final bool localized;

  const AccountFormState({
    required this.accountId,
    this.status = AccountFormStatus.initial,
    this.error = AccountFormError.none,
    this.prepared = false,
    this.editing = false,
    this.saved = false,
    this.type = AccountType.cash,
    this.sortOrder = 0,
    this.archived = false,
    this.name = '',
    this.balanceText = '',
    this.localized = false,
  });

  AccountFormState copyWith({
    AccountFormStatus? status,
    AccountFormError? error,
    String? accountId,
    bool? prepared,
    bool? editing,
    bool? saved,
    AccountType? type,
    int? sortOrder,
    bool? archived,
    String? name,
    String? balanceText,
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
      sortOrder: sortOrder ?? this.sortOrder,
      archived: archived ?? this.archived,
      name: name ?? this.name,
      balanceText: balanceText ?? this.balanceText,
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
    sortOrder,
    archived,
    name,
    balanceText,
    localized,
  ];
}
