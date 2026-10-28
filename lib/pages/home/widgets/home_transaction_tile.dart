import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/core/utils/money_format.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/routes/app_routes.dart';
import 'package:money_manager/themes/ledger_palette.dart';

class HomeTransactionTile extends StatelessWidget {
  const HomeTransactionTile({
    required this.transaction,
    required this.categories,
    required this.locale,
    super.key,
  });

  final TransactionModel transaction;
  final List<CategoryModel> categories;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final category = categories.where(
      (item) => item.id == transaction.categoryId,
    );
    final l10n = context.l10n;
    final title = transaction.note.isNotEmpty
        ? transaction.note
        : (category.isEmpty
              ? switch (transaction.type) {
                  TransactionType.expense => l10n.expense,
                  TransactionType.income => l10n.income,
                  TransactionType.transfer => l10n.transfer,
                }
              : category.first.labelFor(context.categoryLanguageCode));
    final color = switch (transaction.type) {
      TransactionType.income => LedgerPalette.green,
      TransactionType.expense => scheme.primary,
      TransactionType.transfer => scheme.onSurface,
    };
    final signed = transaction.type == TransactionType.transfer
        ? formatMinor(transaction.amountMinor, locale: locale)
        : formatMinor(
            transaction.type == TransactionType.expense
                ? -transaction.amountMinor
                : transaction.amountMinor,
            locale: locale,
            signed: true,
          );
    return ListTile(
      onTap: () =>
          context.push('${AppRoutes.record.path}?id=${transaction.id}'),
      title: Text(title),
      subtitle: Text(DateFormat.MMMd(locale).format(transaction.date)),
      trailing: Text(
        signed,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
      ),
    );
  }
}
