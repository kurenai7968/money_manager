import 'package:material_ui/material_ui.dart';
import 'package:money_manager/models/account_book_kinds.dart';

class CategoriesFrame extends StatefulWidget {
  final Widget child;

  const CategoriesFrame({required this.child, super.key});

  static CategoriesFrameState of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_CategoriesScope>();
    assert(scope != null, 'CategoriesFrame not found');
    return scope!.state;
  }

  @override
  State<CategoriesFrame> createState() => CategoriesFrameState();
}

class CategoriesFrameState extends State<CategoriesFrame>
    with SingleTickerProviderStateMixin {
  late final TabController tabs;

  @override
  void initState() {
    super.initState();
    tabs = TabController(length: CategoryKind.values.length, vsync: this);
  }

  @override
  void dispose() {
    tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _CategoriesScope(state: this, child: widget.child);
  }
}

class _CategoriesScope extends InheritedWidget {
  final CategoriesFrameState state;

  const _CategoriesScope({required this.state, required super.child});

  @override
  bool updateShouldNotify(_CategoriesScope oldWidget) => true;
}
