import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/pages/accounts/bloc/account_detail_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/account_detail_event.dart';
import 'package:money_manager/pages/accounts/widgets/account_detail_app_bar.dart';
import 'package:money_manager/pages/accounts/widgets/account_detail_body.dart';

class AccountDetailPage extends StatelessWidget {
  final int accountId;

  const AccountDetailPage({required this.accountId, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AccountDetailBloc(accountId: accountId, accountBook: context.read())
            ..add(const AccountDetailInitialized()),
      child: Scaffold(
        appBar: AccountDetailAppBar(accountId: accountId),
        body: AccountDetailBody(accountId: accountId),
      ),
    );
  }
}
