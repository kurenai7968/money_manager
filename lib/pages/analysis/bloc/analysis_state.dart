import 'package:equatable/equatable.dart';
import 'package:money_manager/core/utils/analysis_rollup.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';

enum AnalysisStatus { initial, success, failure }

class AnalysisState extends Equatable {
  final AnalysisStatus status;
  final DateTime month;
  final CategoryKind kind;
  final AnalysisRollup rollup;
  final List<CategoryModel> categories;
  final List<AccountModel> accounts;

  const AnalysisState({
    required this.month,
    required this.rollup,
    this.status = AnalysisStatus.initial,
    this.kind = CategoryKind.expense,
    this.categories = const [],
    this.accounts = const [],
  });

  AnalysisState copyWith({
    AnalysisStatus? status,
    DateTime? month,
    CategoryKind? kind,
    AnalysisRollup? rollup,
    List<CategoryModel>? categories,
    List<AccountModel>? accounts,
  }) {
    return AnalysisState(
      status: status ?? this.status,
      month: month ?? this.month,
      kind: kind ?? this.kind,
      rollup: rollup ?? this.rollup,
      categories: categories ?? this.categories,
      accounts: accounts ?? this.accounts,
    );
  }

  @override
  List<Object?> get props => [
    status,
    month,
    kind,
    rollup,
    categories,
    accounts,
  ];
}
