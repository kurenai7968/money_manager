import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/models/category_defaults.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_event.dart';
import 'package:money_manager/pages/categories/bloc/categories_bloc.dart';
import 'package:money_manager/pages/categories/bloc/categories_event.dart';
import 'package:money_manager/pages/home/widgets/home_app_bar.dart';
import 'package:money_manager/pages/home/widgets/home_body.dart';
import 'package:money_manager/pages/home/widgets/home_frame.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_bloc.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_event.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AccountsBloc(context.read(), context.read())
            ..add(const AccountsStarted()),
      child: BlocProvider(
        create: (context) =>
            TransactionsBloc(context.read())..add(const TransactionsStarted()),
        child: BlocProvider(
          create: (context) =>
              CategoriesBloc(context.read(), transactions: context.read())
                ..add(CategoriesStarted(defaultCategories())),
          child: const HomeFrame(
            child: Scaffold(appBar: HomeAppBar(), body: HomeBody()),
          ),
        ),
      ),
    );
  }
}
