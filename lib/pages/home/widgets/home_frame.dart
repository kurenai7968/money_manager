import 'package:flutter/widgets.dart';

enum HomeView { summary, calendar }

class HomeFrame extends StatefulWidget {
  const HomeFrame({required this.child, super.key});

  final Widget child;

  static HomeFrameState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_HomeScope>();
    assert(scope != null, 'HomeFrame not found');
    return scope!.state;
  }

  @override
  State<HomeFrame> createState() => HomeFrameState();
}

class HomeFrameState extends State<HomeFrame> {
  HomeView view = HomeView.summary;
  late DateTime month;
  DateTime? selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    month = DateTime(now.year, now.month);
    selectedDay = DateTime(now.year, now.month, now.day);
  }

  void shiftMonth(int delta) {
    setState(() {
      month = DateTime(month.year, month.month + delta);
      selectedDay = null;
    });
  }

  void toggleView() {
    setState(() {
      view = view == HomeView.summary ? HomeView.calendar : HomeView.summary;
    });
  }

  void selectDay(DateTime day) {
    setState(() => selectedDay = day);
  }

  @override
  Widget build(BuildContext context) {
    return _HomeScope(state: this, child: widget.child);
  }
}

class _HomeScope extends InheritedWidget {
  const _HomeScope({required this.state, required super.child});

  final HomeFrameState state;

  @override
  bool updateShouldNotify(_HomeScope oldWidget) => true;
}
