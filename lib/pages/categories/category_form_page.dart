import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/models/category_defaults.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/pages/categories/bloc/categories_bloc.dart';
import 'package:money_manager/pages/categories/bloc/categories_event.dart';
import 'package:money_manager/pages/categories/widgets/category_form_app_bar.dart';
import 'package:money_manager/pages/categories/widgets/category_form_body.dart';
import 'package:money_manager/pages/page_blocs.dart';

class CategoryFormPage extends StatelessWidget {
  const CategoryFormPage({
    this.categoryId,
    this.initialKind = CategoryKind.expense,
    super.key,
  });

  final String? categoryId;
  final CategoryKind initialKind;

  @override
  Widget build(BuildContext context) {
    Widget child = Scaffold(
      appBar: CategoryFormAppBar(editing: categoryId != null),
      body: CategoryFormBody(categoryId: categoryId, initialKind: initialKind),
    );
    if (!hasBloc<CategoriesBloc>(context)) {
      child = BlocProvider(
        create: (context) =>
            CategoriesBloc(context.read(), transactions: context.read())
              ..add(CategoriesStarted(defaultCategories())),
        child: child,
      );
    }
    return child;
  }
}
