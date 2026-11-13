import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/pages/home/bloc/home_bloc.dart';
import 'package:money_manager/pages/home/bloc/home_event.dart';
import 'package:money_manager/routes/app_routes.dart';

class HomeRecordButton extends StatelessWidget {
  static const listClearance = 88.0;

  const HomeRecordButton({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FloatingActionButton(
      tooltip: context.l10n.record,
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      onPressed: () async {
        await context.push(AppRoutes.record.path);
        if (!context.mounted) {
          return;
        }
        context.read<HomeBloc>().add(const HomeInitialized());
      },
      child: const Icon(Icons.add),
    );
  }
}
