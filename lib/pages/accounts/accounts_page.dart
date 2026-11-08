import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_event.dart';
import 'package:money_manager/pages/accounts/widgets/accounts_app_bar.dart';
import 'package:money_manager/pages/accounts/widgets/accounts_body.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AccountsBloc(context.read(), context.read())
            ..add(const AccountsStarted()),
      child: const Scaffold(appBar: AccountsAppBar(), body: AccountsBody()),
    );
  }
}
