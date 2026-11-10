import 'package:equatable/equatable.dart';
import 'package:money_manager/models/account_book_kinds.dart';

sealed class AnalysisEvent extends Equatable {
  const AnalysisEvent();

  @override
  List<Object?> get props => [];
}

class AnalysisInitialized extends AnalysisEvent {
  const AnalysisInitialized();
}

class AnalysisKindSelected extends AnalysisEvent {
  final CategoryKind kind;

  const AnalysisKindSelected(this.kind);

  @override
  List<Object?> get props => [kind];
}
