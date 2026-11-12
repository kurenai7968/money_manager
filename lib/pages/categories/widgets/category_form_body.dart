import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/account_book_kinds.dart';
import 'package:money_manager/pages/categories/bloc/categories_bloc.dart';
import 'package:money_manager/pages/categories/bloc/categories_event.dart';
import 'package:money_manager/pages/categories/bloc/categories_state.dart';
import 'package:money_manager/pages/categories/widgets/category_icon_choice.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:money_manager/themes/account_book_palette.dart';
import 'package:money_manager/widgets/confirm_delete_dialog.dart';

class CategoryFormBody extends StatefulWidget {
  final int? categoryId;
  final CategoryKind initialKind;

  const CategoryFormBody({
    this.categoryId,
    this.initialKind = CategoryKind.expense,
    super.key,
  });

  @override
  State<CategoryFormBody> createState() => _CategoryFormBodyState();
}

class _CategoryFormBodyState extends State<CategoryFormBody> {
  final _name = TextEditingController();
  String? _icon;
  late CategoryKind _type;
  var _sortOrder = 0;
  var _isActive = true;
  var _ready = false;
  var _waiting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _type = widget.initialKind;
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
      _type = category.type;
      _sortOrder = category.sortOrder;
      _isActive = category.isActive;
      return;
    }
    _sortOrder = _nextSortOrder(state.categories, _type);
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
              selected: {_type},
              onSelectionChanged: (value) {
                final type = value.first;
                final categories = context
                    .read<CategoriesBloc>()
                    .state
                    .categories;
                setState(() {
                  _type = type;
                  _sortOrder = _nextSortOrder(categories, type);
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
              for (final key in AccountBookPalette.iconKeys)
                CategoryIconChoice(
                  iconKey: key,
                  selected: key == _icon,
                  color: AccountBookPalette.directionColor(
                    income: _type == CategoryKind.income,
                  ),
                  onPressed: () => setState(() => _icon = key),
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
          id: widget.categoryId,
          name: text,
          icon: icon,
          type: _type,
          sortOrder: _sortOrder,
          isActive: _isActive,
        ),
      ),
    );
  }

  Future<void> _delete() async {
    final id = widget.categoryId;
    if (id == null) {
      return;
    }
    final confirmed = await showConfirmDeleteDialog(
      context,
      context.l10n.deleteCategoryMessage,
    );
    if (!confirmed || !mounted) {
      return;
    }
    _waiting = true;
    context.read<CategoriesBloc>().add(CategoryDeletePressed(id));
  }
}

int _nextSortOrder(List<CategoryModel> categories, CategoryKind type) {
  final orders = [
    for (final category in categories)
      if (category.type == type) category.sortOrder,
  ];
  if (orders.isEmpty) {
    return 0;
  }
  return orders.reduce((left, right) => left > right ? left : right) + 1;
}
