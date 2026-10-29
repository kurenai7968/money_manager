import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/core/utils/id.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/pages/categories/bloc/categories_bloc.dart';
import 'package:money_manager/pages/categories/bloc/categories_event.dart';
import 'package:money_manager/pages/categories/bloc/categories_state.dart';
import 'package:money_manager/pages/categories/widgets/category_icon_choice.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:money_manager/themes/ledger_palette.dart';

class CategoryFormBody extends StatefulWidget {
  const CategoryFormBody({
    this.categoryId,
    this.initialKind = CategoryKind.expense,
    super.key,
  });

  final String? categoryId;
  final CategoryKind initialKind;

  @override
  State<CategoryFormBody> createState() => _CategoryFormBodyState();
}

class _CategoryFormBodyState extends State<CategoryFormBody> {
  final _name = TextEditingController();
  String? _icon;
  var _color = 'coral';
  late CategoryKind _kind;
  var _sortOrder = 0;
  var _archived = false;
  var _ready = false;
  var _waiting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _kind = widget.initialKind;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _apply(CategoriesState state) {
    if (_ready) {
      return;
    }
    if (state.status != CategoriesStatus.success &&
        state.status != CategoriesStatus.failure) {
      return;
    }
    _ready = true;
    final existing = state.categories.where(
      (category) => category.id == widget.categoryId,
    );
    if (existing.isNotEmpty) {
      final category = existing.first;
      _name.text = category.labelFor(context.categoryLanguageCode);
      _icon = category.icon;
      _color = category.color;
      _kind = category.kind;
      _sortOrder = category.sortOrder;
      _archived = category.archived;
      return;
    }
    _sortOrder = _nextSortOrder(state.categories, _kind);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<CategoriesBloc>().state;
    _apply(state);
    final editing = widget.categoryId != null;
    return BlocListener<CategoriesBloc, CategoriesState>(
      listener: (context, state) {
        if (!_waiting) {
          return;
        }
        if (state.status == CategoriesStatus.success &&
            state.error == CategoriesError.none) {
          context.pop();
        } else if (state.error == CategoriesError.nameRequired) {
          setState(() => _error = l10n.nameRequired);
          _waiting = false;
        }
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.l),
        children: [
          Text(l10n.name, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.s),
          TextField(controller: _name),
          const SizedBox(height: AppSpacing.xl),
          if (!editing)
            SegmentedButton<CategoryKind>(
              segments: [
                ButtonSegment(
                  value: CategoryKind.expense,
                  label: Text(l10n.expense),
                ),
                ButtonSegment(
                  value: CategoryKind.income,
                  label: Text(l10n.income),
                ),
              ],
              selected: {_kind},
              onSelectionChanged: (value) {
                final kind = value.first;
                final categories = context
                    .read<CategoriesBloc>()
                    .state
                    .categories;
                setState(() {
                  _kind = kind;
                  _sortOrder = _nextSortOrder(categories, kind);
                });
              },
            ),
          const SizedBox(height: AppSpacing.xl),
          Text(l10n.icon, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              for (final key in LedgerPalette.iconKeys)
                CategoryIconChoice(
                  iconKey: key,
                  selected: key == _icon,
                  color: LedgerPalette.color(_color),
                  onPressed: () => setState(() => _icon = key),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(l10n.color, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: AppSpacing.m,
            children: [
              for (final key in LedgerPalette.colorKeys)
                IconButton(
                  tooltip: key,
                  onPressed: () => setState(() => _color = key),
                  icon: Icon(
                    key == _color ? Icons.circle : Icons.circle_outlined,
                    color: LedgerPalette.color(key),
                  ),
                ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.m),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          FilledButton(onPressed: _save, child: Text(l10n.save)),
          if (editing) TextButton(onPressed: _delete, child: Text(l10n.delete)),
        ],
      ),
    );
  }

  void _save() {
    final l10n = context.l10n;
    final text = _name.text.trim();
    if (text.isEmpty) {
      setState(() => _error = l10n.nameRequired);
      return;
    }
    final icon = _icon;
    if (icon == null) {
      setState(() => _error = l10n.iconRequired);
      return;
    }
    _waiting = true;
    context.read<CategoriesBloc>().add(
      CategorySavePressed(
        CategoryModel(
          id: widget.categoryId ?? createId(),
          name: text,
          icon: icon,
          color: _color,
          kind: _kind,
          sortOrder: _sortOrder,
          archived: _archived,
        ),
      ),
    );
  }

  void _delete() {
    final id = widget.categoryId;
    if (id == null) {
      return;
    }
    _waiting = true;
    context.read<CategoriesBloc>().add(CategoryDeletePressed(id));
  }
}

int _nextSortOrder(List<CategoryModel> categories, CategoryKind kind) {
  final orders = [
    for (final category in categories)
      if (category.kind == kind) category.sortOrder,
  ];
  if (orders.isEmpty) {
    return 0;
  }
  return orders.reduce((left, right) => left > right ? left : right) + 1;
}
