import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_event.dart';
import 'package:money_manager/pages/accounts/widgets/account_detail_app_bar.dart';
import 'package:money_manager/pages/accounts/widgets/account_detail_body.dart';
import 'package:money_manager/pages/page_blocs.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_bloc.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_event.dart';

class AccountDetailPage extends StatelessWidget {
  const AccountDetailPage({required this.accountId, super.key});

  final String accountId;

  @override
  Widget build(BuildContext context) {
    Widget child = Scaffold(
      appBar: AccountDetailAppBar(accountId: accountId),
      body: AccountDetailBody(accountId: accountId),
    );
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
