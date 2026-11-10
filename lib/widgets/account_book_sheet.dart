import 'package:material_ui/material_ui.dart';

Future<T?> showLedgerSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  double? maxHeightFactor,
}) {
  final size = MediaQuery.sizeOf(context);
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: maxHeightFactor != null,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    constraints: maxHeightFactor == null
        ? null
        : BoxConstraints(maxHeight: size.height * maxHeightFactor),
    builder: builder,
  );
}
