import 'package:flutter/widgets.dart';
import 'package:money_manager/models/ledger_kinds.dart';

class AnalysisFrame extends StatefulWidget {
  const AnalysisFrame({required this.child, super.key});

  final Widget child;

  static AnalysisFrameState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_AnalysisScope>();
    assert(scope != null, 'AnalysisFrame not found');
    return scope!.state;
  }

  @override
  State<AnalysisFrame> createState() => AnalysisFrameState();
}

class AnalysisFrameState extends State<AnalysisFrame> {
  CategoryKind kind = CategoryKind.expense;

  void setKind(CategoryKind value) {
    setState(() => kind = value);
  }

  @override
  Widget build(BuildContext context) {
    return _AnalysisScope(state: this, child: widget.child);
  }
}

class _AnalysisScope extends InheritedWidget {
  const _AnalysisScope({required this.state, required super.child});

  final AnalysisFrameState state;

  @override
  bool updateShouldNotify(_AnalysisScope oldWidget) => true;
}
