import 'package:equatable/equatable.dart';
import 'package:money_manager/models/ledger_kinds.dart';

sealed class AnalysisEvent extends Equatable {
  const AnalysisEvent();

  @override
  List<Object?> get props => [];
}

class AnalysisStarted extends AnalysisEvent {
  const AnalysisStarted();
}

class AnalysisKindSelected extends AnalysisEvent {
  final CategoryKind kind;

  const AnalysisKindSelected(this.kind);

  @override
  List<Object?> get props => [kind];
}

class AnalysisSourcesChanged extends AnalysisEvent {
  const AnalysisSourcesChanged();
}
