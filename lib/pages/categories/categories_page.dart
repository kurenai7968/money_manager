import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/models/category_defaults.dart';
import 'package:money_manager/pages/categories/bloc/categories_bloc.dart';
import 'package:money_manager/pages/categories/bloc/categories_event.dart';
import 'package:money_manager/pages/categories/widgets/categories_app_bar.dart';
import 'package:money_manager/pages/categories/widgets/categories_body.dart';
import 'package:money_manager/pages/categories/widgets/categories_frame.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CategoriesBloc(context.read(), transactions: context.read())
            ..add(CategoriesStarted(defaultCategories())),
      child: const CategoriesFrame(
        child: Scaffold(appBar: CategoriesAppBar(), body: CategoriesBody()),
      ),
    );
  }
}
