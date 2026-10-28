import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/pages/categories/bloc/categories_bloc.dart';
import 'package:money_manager/pages/categories/bloc/categories_state.dart';
import 'package:money_manager/pages/categories/widgets/category_list.dart';
import 'package:money_manager/routes/app_routes.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: CategoryKind.values.length, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.categories),
        actions: [
          TextButton(
            onPressed: () => context.push(
              AppRoutes.categoryNew.path,
              extra: CategoryKind.values[_tabs.index],
            ),
            child: Text(l10n.add),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            for (final kind in CategoryKind.values)
              Tab(
                text: kind == CategoryKind.expense ? l10n.expense : l10n.income,
              ),
          ],
        ),
      ),
      body: BlocBuilder<CategoriesBloc, CategoriesState>(
        builder: (context, state) {
          return TabBarView(
            controller: _tabs,
            children: [
              for (final kind in CategoryKind.values)
                CategoryList(
                  key: ValueKey(kind),
                  categories: [
                    for (final category in state.active)
                      if (category.kind == kind) category,
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}
