import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_bloc.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/core/utils/cached_date_format.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/models/account_book_kinds.dart';
import 'package:money_manager/pages/record/bloc/record_bloc.dart';
import 'package:money_manager/pages/record/bloc/record_event.dart';
import 'package:money_manager/pages/record/widgets/record_date_dialog.dart';
import 'package:money_manager/widgets/base_app_bar.dart';
import 'package:money_manager/widgets/confirm_delete_dialog.dart';

class RecordAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RecordAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 48);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RecordBloc>().state;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    return BaseAppBar(
      title: TextButton(
        onPressed: () => _pickDate(context),
        child: Text(
          _title(locale, state.date),
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      actions: [
        if (state.transactionId != null)
          TextButton(
            onPressed: () => _delete(context),
            child: Text(l10n.delete),
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Row(
          children: [
            for (final type in TransactionType.values)
              Expanded(
                child: TextButton(
                  onPressed: () =>
                      context.read<RecordBloc>().add(RecordTypeSelected(type)),
                  child: Text(
                    _typeLabel(l10n, type),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: state.type == type
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: state.type == type
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showConfirmDeleteDialog(
      context,
      context.l10n.deleteTransactionMessage,
    );
    if (confirmed && context.mounted) {
      context.read<RecordBloc>().add(const RecordDeletePressed());
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final bloc = context.read<RecordBloc>();
    final firstDay = context
        .read<AppSettingBloc>()
        .state
        .appSetting
        .firstDayOfWeek;
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        return RecordDateDialog(
          initial: bloc.state.date,
          firstDayOfWeek: firstDay,
        );
      },
    );
    if (picked != null) {
      bloc.add(RecordDateSelected(picked));
    }
  }
}

String _title(String locale, DateTime date) {
  return locale.startsWith('zh')
      ? cachedDateFormat(locale, 'M月d日').format(date)
      : cachedMonthDay(locale).format(date);
}

String _typeLabel(AppLocalizations l10n, TransactionType value) {
  return switch (value) {
    TransactionType.expense => l10n.expense,
    TransactionType.income => l10n.income,
    TransactionType.transfer => l10n.transfer,
  };
}
