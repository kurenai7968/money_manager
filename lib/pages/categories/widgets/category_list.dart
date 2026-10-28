import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/pages/categories/bloc/categories_bloc.dart';
import 'package:money_manager/pages/categories/bloc/categories_event.dart';
import 'package:money_manager/routes/app_routes.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:money_manager/themes/ledger_palette.dart';
import 'package:money_manager/widgets/ledger_reorder.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({required this.categories, super.key});

  final List<CategoryModel> categories;

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  late List<CategoryModel> _categories = widget.categories;

  @override
  void didUpdateWidget(CategoryList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _categories = syncReorder(
      _categories,
      widget.categories,
      (category) => category.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      proxyDecorator: ledgerReorderProxy,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      itemCount: _categories.length,
      onReorderItem: _reorder,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return ListTile(
          key: ValueKey(category.id),
          onTap: () => context.push(AppRoutes.editCategory(category.id)),
          leading: CircleAvatar(
            backgroundColor: LedgerPalette.color(category.color),
            child: Icon(
              LedgerPalette.icon(category.icon),
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          title: Text(category.labelFor(context.categoryLanguageCode)),
          trailing: ReorderableDragStartListener(
            index: index,
            child: Icon(
              Icons.drag_handle,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }

  void _reorder(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= _categories.length ||
        oldIndex == newIndex) {
      return;
    }
    final updated = [..._categories];
    final moved = updated.removeAt(oldIndex);
    var target = newIndex;
    if (target < 0) {
      target = 0;
    } else if (target > updated.length) {
      target = updated.length;
    }
    updated.insert(target, moved);
    setState(() => _categories = updated);
    context.read<CategoriesBloc>().add(
      CategoriesReorderPressed(moved.kind, [
        for (final category in updated) category.id,
      ]),
    );
  }
}
