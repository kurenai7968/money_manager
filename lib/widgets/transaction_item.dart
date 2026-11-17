import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/utils/cached_date_format.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/core/utils/money_format.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/account_book_kinds.dart';
import 'package:money_manager/models/day_ledger.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/routes/app_routes.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:money_manager/themes/account_book_palette.dart';

class TransactionList extends StatefulWidget {
  final List<DayLedger> days;
  final List<CategoryModel> categories;
  final List<AccountModel> accounts;
  final String locale;
  final EdgeInsets? padding;
  final VoidCallback? onReturned;

  const TransactionList({
    required this.days,
    required this.categories,
    required this.accounts,
    required this.locale,
    this.padding,
    this.onReturned,
    super.key,
  });

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  final _collapsed = <DateTime>{};

  void _toggle(DateTime day) {
    setState(() {
      if (!_collapsed.remove(day)) {
        _collapsed.add(day);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesById = _firstById(
      widget.categories,
      (category) => category.id,
    );
    final accountsById = _firstById(widget.accounts, (account) => account.id);
    final listPadding =
        widget.padding ?? const EdgeInsets.only(bottom: AppSpacing.s);
    final entries = <_Entry>[];
    for (var index = 0; index < widget.days.length; index++) {
      final day = widget.days[index];
      final collapsed = _collapsed.contains(day.day);
      entries.add(
        _DayHeaderEntry(
          day: day.day,
          expense: day.expense,
          first: index == 0,
          collapsed: collapsed,
        ),
      );
      if (collapsed) {
        continue;
      }
      for (
        var itemIndex = 0;
        itemIndex < day.transactions.length;
        itemIndex++
      ) {
        entries.add(
          _TransactionEntry(
            transaction: day.transactions[itemIndex],
            divider: itemIndex > 0,
          ),
        );
      }
    }
    return ListView.builder(
      padding: listPadding,
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return switch (entry) {
          _DayHeaderEntry(
            :final day,
            :final expense,
            :final first,
            :final collapsed,
          ) =>
            _TransactionDayHeader(
              day: day,
              expense: expense,
              locale: widget.locale,
              first: first,
              collapsed: collapsed,
              onToggle: () => _toggle(day),
            ),
          _TransactionEntry(:final transaction, :final divider) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (divider)
                Divider(
                  height: 1,
                  color: Theme.of(context).colorScheme.outline,
                ),
              TransactionItem(
                transaction: transaction,
                categories: widget.categories,
                accounts: widget.accounts,
                categoriesById: categoriesById,
                accountsById: accountsById,
                locale: widget.locale,
                onReturned: widget.onReturned,
              ),
            ],
          ),
        };
      },
    );
  }
}

class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;
  final List<CategoryModel> categories;
  final List<AccountModel> accounts;
  final String locale;
  final Map<int, CategoryModel>? categoriesById;
  final Map<int, AccountModel>? accountsById;
  final VoidCallback? onReturned;

  const TransactionItem({
    required this.transaction,
    required this.categories,
    required this.accounts,
    required this.locale,
    this.categoriesById,
    this.accountsById,
    this.onReturned,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final languageCode = context.categoryLanguageCode;
    final category = _category();
    final title = category == null
        ? _typeLabel(context)
        : category.labelFor(languageCode);
    final note = transaction.note.trim();
    final accountLabel = _accountLabel(languageCode);
    final muted = Theme.of(context).textTheme.bodyMedium
        ?.copyWith(color: scheme.onSurfaceVariant);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () async {
          await context.push(AppRoutes.recordLocation(id: transaction.id));
          if (!context.mounted) {
            return;
          }
          onReturned?.call();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.l,
            vertical: AppSpacing.s,
          ),
          child: Row(
            children: [
              ExcludeSemantics(
                child: _TransactionIcon(
                  category: category,
                  type: transaction.type,
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s),
                        Text(
                          _amount(),
                          maxLines: 1,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: _amountColor(context)),
                        ),
                      ],
                    ),
                    if (note.isNotEmpty || accountLabel.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Expanded(
                            child: note.isEmpty
                                ? const SizedBox.shrink()
                                : _NoteText(note: note, style: muted),
                          ),
                          if (accountLabel.isNotEmpty) ...[
                            const SizedBox(width: AppSpacing.s),
                            Flexible(
                              child: Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: Text(
                                  accountLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                  style: muted,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  CategoryModel? _category() {
    final indexed = categoriesById;
    final categoryId = transaction.categoryId;
    if (indexed != null) {
      return categoryId == null ? null : indexed[categoryId];
    }
    for (final item in categories) {
      if (item.id == categoryId) {
        return item;
      }
    }
    return null;
  }

  String _typeLabel(BuildContext context) {
    final l10n = context.l10n;
    return switch (transaction.type) {
      TransactionType.expense => l10n.expense,
      TransactionType.income => l10n.income,
      TransactionType.transfer => l10n.transfer,
    };
  }

  String _accountLabel(String languageCode) {
    String nameOf(int? id) {
      if (id == null) {
        return '';
      }
      final indexed = accountsById;
      if (indexed != null) {
        return indexed[id]?.labelFor(languageCode) ?? '';
      }
      for (final account in accounts) {
        if (account.id == id) {
          return account.labelFor(languageCode);
        }
      }
      return '';
    }

    if (transaction.type == TransactionType.transfer) {
      final from = nameOf(transaction.fromAccountId);
      final to = nameOf(transaction.toAccountId);
      if (from.isEmpty) {
        return to;
      }
      if (to.isEmpty) {
        return from;
      }
      return '$from → $to';
    }
    return nameOf(transaction.accountId);
  }

  String _amount() {
    final amount = transaction.amount;
    if (transaction.type == TransactionType.transfer) {
      return formatAmount(amount, locale: locale);
    }
    return formatAmount(
      transaction.type == TransactionType.expense ? -amount : amount,
      locale: locale,
      signed: true,
    );
  }

  Color _amountColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (transaction.type == TransactionType.transfer) {
      return scheme.onSurface;
    }
    return AccountBookPalette.directionColor(
      income: transaction.type == TransactionType.income,
    );
  }
}

class _TransactionIcon extends StatelessWidget {
  final CategoryModel? category;
  final TransactionType type;

  const _TransactionIcon({required this.category, required this.type});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final IconData icon;
    final Color background;
    final Color foreground;
    final known = category;
    if (known != null) {
      icon = AccountBookPalette.icon(known.icon);
      background = AccountBookPalette.directionColor(
        income: type == TransactionType.income,
      );
      foreground = scheme.onPrimary;
    } else {
      background = scheme.surfaceContainerHighest;
      foreground = scheme.onSurface;
      icon = switch (type) {
        TransactionType.transfer => Icons.swap_horiz,
        _ => Icons.circle_outlined,
      };
    }
    return CircleAvatar(
      backgroundColor: background,
      child: Icon(icon, color: foreground),
    );
  }
}

class _NoteText extends StatelessWidget {
  final String note;
  final TextStyle? style;

  const _NoteText({required this.note, required this.style});

  @override
  Widget build(BuildContext context) {
    final base = style;
    final matches = _noteTag.allMatches(note);
    if (base == null || matches.isEmpty) {
      return Text(
        note,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: base,
      );
    }
    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final match in matches) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: note.substring(cursor, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(0),
          style: base.copyWith(color: AccountBookPalette.green),
        ),
      );
      cursor = match.end;
    }
    if (cursor < note.length) {
      spans.add(TextSpan(text: note.substring(cursor)));
    }
    return Text.rich(
      TextSpan(style: base, children: spans),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _TransactionDayHeader extends StatelessWidget {
  final DateTime day;
  final double expense;
  final String locale;
  final bool first;
  final bool collapsed;
  final VoidCallback onToggle;

  const _TransactionDayHeader({
    required this.day,
    required this.expense,
    required this.locale,
    required this.first,
    required this.collapsed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.labelMedium
        ?.copyWith(color: scheme.onSurfaceVariant);
    return Semantics(
      button: true,
      expanded: !collapsed,
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.l,
            first ? AppSpacing.s : AppSpacing.m,
            AppSpacing.l,
            AppSpacing.s,
          ),
          child: Row(
            children: [
              ExcludeSemantics(
                child: Icon(
                  collapsed ? Icons.chevron_right : Icons.expand_more,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  cachedDateFormat(locale, 'M/d (E)').format(day),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style,
                ),
              ),
              if (expense > 0) ...[
                const SizedBox(width: AppSpacing.s),
                Flexible(
                  child: Text(
                    '${context.l10n.expense} ${formatAmount(expense, locale: locale)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

final _noteTag = RegExp(r'#[^\s#]+');

sealed class _Entry {}

class _DayHeaderEntry extends _Entry {
  final DateTime day;
  final double expense;
  final bool first;
  final bool collapsed;

  _DayHeaderEntry({
    required this.day,
    required this.expense,
    required this.first,
    required this.collapsed,
  });
}

class _TransactionEntry extends _Entry {
  final TransactionModel transaction;
  final bool divider;

  _TransactionEntry({required this.transaction, required this.divider});
}

Map<int, T> _firstById<T>(List<T> items, int? Function(T item) idOf) {
  final index = <int, T>{};
  for (final item in items) {
    final id = idOf(item);
    if (id != null) {
      index.putIfAbsent(id, () => item);
    }
  }
  return index;
}
