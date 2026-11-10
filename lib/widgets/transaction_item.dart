import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/utils/cached_date_format.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/core/utils/money_format.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/account_book_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/routes/app_routes.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:money_manager/themes/account_book_palette.dart';

class TransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;
  final List<CategoryModel> categories;
  final List<AccountModel> accounts;
  final String locale;
  final bool showDayHeaders;

  const TransactionList({
    required this.transactions,
    required this.categories,
    required this.accounts,
    required this.locale,
    this.showDayHeaders = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final categoriesById = _firstById(categories, (category) => category.id);
    final accountsById = _firstById(accounts, (account) => account.id);
    if (!showDayHeaders) {
      return ListView.separated(
        itemCount: transactions.length,
        separatorBuilder: (context, _) =>
            Divider(height: 1, color: Theme.of(context).colorScheme.outline),
        itemBuilder: (context, index) {
          return TransactionItem(
            transaction: transactions[index],
            categories: categories,
            accounts: accounts,
            categoriesById: categoriesById,
            accountsById: accountsById,
            locale: locale,
          );
        },
      );
    }

    final groups = _groupByDay(transactions);
    final entries = <_Entry>[];
    for (var index = 0; index < groups.length; index++) {
      final group = groups[index];
      entries.add(
        _DayHeaderEntry(
          day: group.day,
          expenseMinor: group.expenseMinor,
          first: index == 0,
        ),
      );
      for (var itemIndex = 0; itemIndex < group.items.length; itemIndex++) {
        entries.add(
          _TransactionEntry(
            transaction: group.items[itemIndex],
            divider: itemIndex > 0,
          ),
        );
      }
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return switch (entry) {
          _DayHeaderEntry(:final day, :final expenseMinor, :final first) =>
            _TransactionDayHeader(
              day: day,
              expenseMinor: expenseMinor,
              locale: locale,
              first: first,
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
                categories: categories,
                accounts: accounts,
                categoriesById: categoriesById,
                accountsById: accountsById,
                locale: locale,
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
  final Map<String, CategoryModel>? categoriesById;
  final Map<String, AccountModel>? accountsById;

  const TransactionItem({
    required this.transaction,
    required this.categories,
    required this.accounts,
    required this.locale,
    this.categoriesById,
    this.accountsById,
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
        onTap: () =>
            context.push('${AppRoutes.record.path}?id=${transaction.id}'),
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
                              ?.copyWith(
                                color: _amountColor(context, category),
                              ),
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
    String nameOf(String? id) {
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
    final minor = transaction.amountMinor;
    if (transaction.type == TransactionType.transfer) {
      return formatMinor(minor, locale: locale);
    }
    return formatMinor(
      transaction.type == TransactionType.expense ? -minor : minor,
      locale: locale,
      signed: true,
    );
  }

  Color _amountColor(BuildContext context, CategoryModel? category) {
    final scheme = Theme.of(context).colorScheme;
    if (transaction.type == TransactionType.transfer) {
      return scheme.onSurface;
    }
    if (category != null) {
      return AccountBookPalette.color(category.color);
    }
    return transaction.type == TransactionType.income
        ? AccountBookPalette.green
        : scheme.primary;
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
      background = AccountBookPalette.color(known.color);
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
  final int expenseMinor;
  final String locale;
  final bool first;

  const _TransactionDayHeader({
    required this.day,
    required this.expenseMinor,
    required this.locale,
    required this.first,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.labelMedium
        ?.copyWith(color: scheme.onSurfaceVariant);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.l,
        first ? AppSpacing.s : AppSpacing.m,
        AppSpacing.l,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              cachedDateFormat(locale, 'M/d (E)').format(day),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
          if (expenseMinor > 0) ...[
            const SizedBox(width: AppSpacing.s),
            Flexible(
              child: Text(
                '${context.l10n.expense} ${formatMinor(expenseMinor, locale: locale)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DayGroup {
  final DateTime day;
  final List<TransactionModel> items;

  _DayGroup(this.day, this.items);

  int get expenseMinor {
    var total = 0;
    for (final item in items) {
      if (item.type == TransactionType.expense) {
        total += item.amountMinor;
      }
    }
    return total;
  }
}

sealed class _Entry {}

class _DayHeaderEntry extends _Entry {
  final DateTime day;
  final int expenseMinor;
  final bool first;

  _DayHeaderEntry({
    required this.day,
    required this.expenseMinor,
    required this.first,
  });
}

class _TransactionEntry extends _Entry {
  final TransactionModel transaction;
  final bool divider;

  _TransactionEntry({required this.transaction, required this.divider});
}

final _noteTag = RegExp(r'#[^\s#]+');

Map<String, T> _firstById<T>(List<T> items, String Function(T item) idOf) {
  final index = <String, T>{};
  for (final item in items) {
    index.putIfAbsent(idOf(item), () => item);
  }
  return index;
}

List<_DayGroup> _groupByDay(List<TransactionModel> transactions) {
  final groups = <_DayGroup>[];
  final indexByDay = <DateTime, int>{};
  for (final transaction in transactions) {
    final day = DateTime(
      transaction.date.year,
      transaction.date.month,
      transaction.date.day,
    );
    final index = indexByDay[day];
    if (index == null) {
      indexByDay[day] = groups.length;
      groups.add(_DayGroup(day, [transaction]));
    } else {
      groups[index].items.add(transaction);
    }
  }
  return groups;
}
