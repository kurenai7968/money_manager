import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_event.dart';
import 'package:money_manager/pages/accounts/widgets/account_form_app_bar.dart';
import 'package:money_manager/pages/accounts/widgets/account_form_body.dart';
import 'package:money_manager/pages/page_blocs.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_bloc.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_event.dart';

class AccountFormPage extends StatelessWidget {
  const AccountFormPage({this.accountId, super.key});

  final String? accountId;

  @override
  Widget build(BuildContext context) {
    Widget child = Scaffold(
      appBar: AccountFormAppBar(editing: accountId != null),
      body: AccountFormBody(accountId: accountId),
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
            AccountsBloc(context.read(), context.read())
              ..add(const AccountsStarted()),
        child: child,
      );
    }
    return child;
  }
}
