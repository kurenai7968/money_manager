import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/pages/categories/widgets/categories_frame.dart';
import 'package:money_manager/routes/app_routes.dart';

class CategoriesAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CategoriesAppBar({super.key});

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight + kTextTabBarHeight);

  @override
  Widget build(BuildContext context) {
    final frame = CategoriesFrame.of(context);
    final l10n = context.l10n;
    return AppBar(
      title: Text(l10n.categories),
      actions: [
        TextButton(
          onPressed: () => context.push(
            AppRoutes.categoryNew.path,
            extra: CategoryKind.values[frame.tabs.index],
          ),
          child: Text(l10n.add),
        ),
      ],
      bottom: TabBar(
        controller: frame.tabs,
        tabs: [
          for (final kind in CategoryKind.values)
            Tab(
              text: kind == CategoryKind.expense ? l10n.expense : l10n.income,
            ),
        ],
      ),
    );
  }
}
