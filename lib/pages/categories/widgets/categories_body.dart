import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/models/account_book_kinds.dart';
import 'package:money_manager/pages/categories/bloc/categories_bloc.dart';
import 'package:money_manager/pages/categories/bloc/categories_state.dart';
import 'package:money_manager/pages/categories/widgets/categories_frame.dart';
import 'package:money_manager/pages/categories/widgets/category_list.dart';

class CategoriesBody extends StatelessWidget {
  const CategoriesBody({super.key});

  @override
  Widget build(BuildContext context) {
    final tabs = CategoriesFrame.of(context).tabs;
    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, state) {
        return TabBarView(
          controller: tabs,
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
    );
  }
}
