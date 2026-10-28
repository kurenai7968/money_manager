import 'package:material_ui/material_ui.dart';

/// Dragged row uses the page background, so the row does not flash another color.
Widget ledgerReorderProxy(Widget child, int _, Animation<double> _) {
  return Builder(
    builder: (context) {
      return Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        child: child,
      );
    },
  );
}

/// Keeps a drag order while [incoming] is still the previous order.
///
/// The saved list arrives a frame later. Adopting it early paints the old
/// order for that frame.
List<T> syncReorder<T>(
  List<T> current,
  List<T> incoming,
  String Function(T item) idOf,
) {
  if (_sameOrder(current, incoming, idOf)) {
    return incoming;
  }
  final incomingIds = incoming.map(idOf).toSet();
  final currentIds = current.map(idOf).toSet();
  if (incomingIds.length == currentIds.length &&
      incomingIds.containsAll(currentIds)) {
    final byId = {for (final item in incoming) idOf(item): item};
    return [for (final item in current) byId[idOf(item)]!];
  }
  return incoming;
}

bool _sameOrder<T>(
  List<T> current,
  List<T> incoming,
  String Function(T item) idOf,
) {
  if (current.length != incoming.length) {
    return false;
  }
  for (var index = 0; index < current.length; index++) {
    if (idOf(current[index]) != idOf(incoming[index])) {
      return false;
    }
  }
  return true;
}
