import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/models/category_defaults.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_event.dart';
import 'package:money_manager/pages/categories/bloc/categories_bloc.dart';
import 'package:money_manager/pages/categories/bloc/categories_event.dart';
import 'package:money_manager/pages/record/bloc/record_bloc.dart';
import 'package:money_manager/pages/record/bloc/record_event.dart';
import 'package:money_manager/pages/record/bloc/record_state.dart';
import 'package:money_manager/pages/record/widgets/record_app_bar.dart';
import 'package:money_manager/pages/record/widgets/record_body.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_bloc.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_event.dart';

class RecordPage extends StatelessWidget {
  const RecordPage({
    this.transactionId,
    this.initialType,
    this.initialAccountId,
    super.key,
  });

  final String? transactionId;
  final TransactionType? initialType;
  final String? initialAccountId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AccountsBloc(context.read(), context.read())
            ..add(const AccountsStarted()),
      child: BlocProvider(
        create: (context) =>
            TransactionsBloc(context.read(), context.read())
              ..add(const TransactionsStarted()),
        child: BlocProvider(
          create: (context) =>
              CategoriesBloc(context.read(), transactions: context.read())
                ..add(CategoriesStarted(defaultCategories())),
          child: BlocProvider(
            create: (context) =>
                RecordBloc(
                  transactions: context.read(),
                  accounts: context.read(),
                  categories: context.read(),
                )..add(
                  RecordStarted(
                    transactionId: transactionId,
                    initialType: initialType,
                    initialAccountId: initialAccountId,
                  ),
                ),
            child: BlocListener<RecordBloc, RecordState>(
              listenWhen: (previous, current) =>
                  current.closePage && !previous.closePage,
              listener: (context, state) => context.pop(),
              child: const Scaffold(appBar: RecordAppBar(), body: RecordBody()),
            ),
          ),
        ),
      ),
    );
  }
}
