import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/pages/categories/bloc/categories_bloc.dart';
import 'package:money_manager/pages/categories/bloc/categories_event.dart';
import 'package:money_manager/pages/categories/bloc/categories_state.dart';
import 'package:money_manager/routes/app_routes.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:money_manager/themes/ledger_palette.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.categories),
        actions: [
          TextButton(
            onPressed: () => context.push(AppRoutes.categoryNew.path),
            child: Text(l10n.add),
          ),
        ],
      ),
      body: BlocBuilder<CategoriesBloc, CategoriesState>(
        builder: (context, state) {
          final active = state.active;
          return CustomScrollView(
            slivers: [
              for (final kind in CategoryKind.values) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.l,
                      AppSpacing.xl,
                      AppSpacing.l,
                      AppSpacing.s,
                    ),
                    child: Text(
                      kind == CategoryKind.expense ? l10n.expense : l10n.income,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                _CategorySliver(
                  categories: active
                      .where((category) => category.kind == kind)
                      .toList(),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _CategorySliver extends StatelessWidget {
  const _CategorySliver({required this.categories});

  final List<CategoryModel> categories;

  @override
  Widget build(BuildContext context) {
    return SliverReorderableList(
      itemCount: categories.length,
      onReorderItem: (oldIndex, newIndex) {
        final updated = [...categories];
        final moved = updated.removeAt(oldIndex);
        updated.insert(newIndex, moved);
        context.read<CategoriesBloc>().add(
          CategoriesReorderPressed(
            updated.first.kind,
            updated.map((category) => category.id).toList(),
          ),
        );
      },
      itemBuilder: (context, index) {
        final category = categories[index];
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
          title: Text(category.name),
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
}
