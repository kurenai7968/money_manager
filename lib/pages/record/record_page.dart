import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/models/category_defaults.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_event.dart';
import 'package:money_manager/pages/categories/bloc/categories_bloc.dart';
import 'package:money_manager/pages/categories/bloc/categories_event.dart';
import 'package:money_manager/pages/page_blocs.dart';
import 'package:money_manager/pages/record/widgets/record_app_bar.dart';
import 'package:money_manager/pages/record/widgets/record_body.dart';
import 'package:money_manager/pages/record/widgets/record_frame.dart';
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
    Widget child = RecordFrame(
      transactionId: transactionId,
      initialType: initialType,
      initialAccountId: initialAccountId,
      child: const Scaffold(appBar: RecordAppBar(), body: RecordBody()),
    );
    if (!hasBloc<CategoriesBloc>(context)) {
      child = BlocProvider(
        create: (context) =>
            CategoriesBloc(context.read(), transactions: context.read())
              ..add(CategoriesStarted(defaultCategories())),
        child: child,
      );
    }
    if (!hasBloc<TransactionsBloc>(context)) {
      child = BlocProvider(
        create: (context) =>
            TransactionsBloc(context.read())..add(const TransactionsStarted()),
        child: child,
      );
    }
    if (!hasBloc<AccountsBloc>(context)) {
      child = BlocProvider(
        create: (context) =>
            AccountsBloc(context.read())..add(const AccountsStarted()),
        child: child,
      );
    }
    return child;
  }
}
