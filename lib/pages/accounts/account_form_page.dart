import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/pages/accounts/bloc/account_form_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/account_form_event.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_event.dart';
import 'package:money_manager/pages/accounts/widgets/account_form_app_bar.dart';
import 'package:money_manager/pages/accounts/widgets/account_form_body.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_bloc.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_event.dart';

class AccountFormPage extends StatelessWidget {
  const AccountFormPage({this.accountId, super.key});

  final String? accountId;

  @override
  Widget build(BuildContext context) {
    final languageCode = context.categoryLanguageCode;
    final locale = Localizations.localeOf(context).toString();
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
              AccountFormBloc(
                accounts: context.read(),
                transactions: context.read(),
              )..add(
                AccountFormStarted(
                  accountId: accountId,
                  languageCode: languageCode,
                  locale: locale,
                ),
              ),
          child: Scaffold(
            appBar: AccountFormAppBar(editing: accountId != null),
            body: AccountFormBody(accountId: accountId),
          ),
        ),
      ),
    );
  }
}
