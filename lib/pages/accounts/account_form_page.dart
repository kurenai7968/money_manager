import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/pages/accounts/bloc/account_form_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/account_form_event.dart';
import 'package:money_manager/pages/accounts/widgets/account_form_app_bar.dart';
import 'package:money_manager/pages/accounts/widgets/account_form_body.dart';

class AccountFormPage extends StatelessWidget {
  final int? accountId;

  const AccountFormPage({this.accountId, super.key});

  @override
  Widget build(BuildContext context) {
    final languageCode = context.categoryLanguageCode;
    final locale = Localizations.localeOf(context).toString();
    return BlocProvider(
      create: (context) =>
          AccountFormBloc(accounts: context.read(), accountBook: context.read())
            ..add(
              AccountFormInitialized(
                accountId: accountId,
                languageCode: languageCode,
                locale: locale,
              ),
            ),
      child: Scaffold(
        appBar: AccountFormAppBar(editing: accountId != null),
        body: AccountFormBody(accountId: accountId),
      ),
    );
  }
}
