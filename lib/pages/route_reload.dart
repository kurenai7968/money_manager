import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

mixin RouteReload<T extends StatefulWidget> on State<T> {
  GoRouterDelegate? _delegate;

  void reloadForRoute();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final delegate = GoRouter.maybeOf(context)?.routerDelegate;
    if (identical(delegate, _delegate)) {
      return;
    }
    _delegate?.removeListener(_scheduleReload);
    _delegate = delegate;
    _delegate?.addListener(_scheduleReload);
  }

  @override
  void dispose() {
    _delegate?.removeListener(_scheduleReload);
    _delegate = null;
    super.dispose();
  }

  void _scheduleReload() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      reloadForRoute();
    });
  }
}
