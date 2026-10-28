import 'package:material_ui/material_ui.dart';

Future<T?> showLedgerSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    builder: builder,
  );
}
