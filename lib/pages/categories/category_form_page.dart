import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/models/category_defaults.dart';
import 'package:money_manager/models/account_book_kinds.dart';
import 'package:money_manager/pages/categories/bloc/categories_bloc.dart';
import 'package:money_manager/pages/categories/bloc/categories_event.dart';
import 'package:money_manager/pages/categories/widgets/category_form_app_bar.dart';
import 'package:money_manager/pages/categories/widgets/category_form_body.dart';

class CategoryFormPage extends StatelessWidget {
  final int? categoryId;
  final CategoryKind initialKind;

  const CategoryFormPage({
    this.categoryId,
    this.initialKind = CategoryKind.expense,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CategoriesBloc(context.read(), transactions: context.read())
            ..add(CategoriesInitialized(defaultCategories())),
      child: Scaffold(
        appBar: CategoryFormAppBar(editing: categoryId != null),
        body: CategoryFormBody(
          categoryId: categoryId,
          initialKind: initialKind,
        ),
      ),
    );
  }
}
