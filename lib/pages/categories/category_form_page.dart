import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/core/utils/id.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/pages/categories/bloc/categories_bloc.dart';
import 'package:money_manager/pages/categories/bloc/categories_event.dart';
import 'package:money_manager/pages/categories/bloc/categories_state.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:money_manager/themes/ledger_palette.dart';

class CategoryFormPage extends StatefulWidget {
  const CategoryFormPage({this.categoryId, super.key});

  final String? categoryId;

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final _name = TextEditingController();
  var _icon = 'other';
  var _color = 'coral';
  var _kind = CategoryKind.expense;
  var _sortOrder = 0;
  var _archived = false;
  String? _languageEn;
  String? _languageZh;
  String? _languageZhCn;
  var _localized = false;
  var _ready = false;
  var _waiting = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) {
      return;
    }
    _ready = true;
    final categories = context.read<CategoriesBloc>().state.categories;
    final existing = categories.where(
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
      _languageEn = category.languageEn;
      _languageZh = category.languageZh;
      _languageZhCn = category.languageZhCn;
      _localized =
          category.languageEn != null ||
          category.languageZh != null ||
          category.languageZhCn != null;
    } else {
      final sameKind = categories.where((category) => category.kind == _kind);
      final orders = sameKind.map((category) => category.sortOrder);
      _sortOrder = orders.isEmpty
          ? 0
          : orders.reduce((a, b) => a > b ? a : b) + 1;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
      child: Scaffold(
        appBar: AppBar(
          title: Text(editing ? l10n.editCategory : l10n.newCategory),
        ),
        body: ListView(
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
                onSelectionChanged: (value) =>
                    setState(() => _kind = value.first),
              ),
            const SizedBox(height: AppSpacing.xl),
            Text(l10n.icon, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AppSpacing.s),
            Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.s,
              children: [
                for (final key in LedgerPalette.iconKeys)
                  IconButton(
                    tooltip: key,
                    isSelected: key == _icon,
                    onPressed: () => setState(() => _icon = key),
                    icon: Icon(LedgerPalette.icon(key)),
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
            if (editing)
              TextButton(onPressed: _delete, child: Text(l10n.delete)),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = context.l10n.nameRequired);
      return;
    }
    _waiting = true;
    final text = _name.text.trim();
    final code = context.categoryLanguageCode;
    context.read<CategoriesBloc>().add(
      CategorySavePressed(
        CategoryModel(
          id: widget.categoryId ?? createId(),
          name: _localized ? null : text,
          languageEn: _localized ? (code == 'en' ? text : _languageEn) : null,
          languageZh: _localized ? (code == 'zh' ? text : _languageZh) : null,
          languageZhCn: _localized
              ? (code == 'zh_CN' ? text : _languageZhCn)
              : null,
          icon: _icon,
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
