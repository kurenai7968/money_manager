import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_bloc.dart';
import 'package:money_manager/models/category_defaults.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_event.dart';
import 'package:money_manager/pages/categories/bloc/categories_bloc.dart';
import 'package:money_manager/pages/categories/bloc/categories_event.dart';
import 'package:money_manager/pages/home/bloc/home_bloc.dart';
import 'package:money_manager/pages/home/bloc/home_event.dart';
import 'package:money_manager/pages/home/bloc/home_state.dart';
import 'package:money_manager/pages/home/widgets/home_calendar_view.dart';
import 'package:money_manager/pages/home/widgets/home_summary_view.dart';
import 'package:money_manager/pages/route_reload.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_bloc.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_event.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> with RouteReload {
  @override
  void reloadForRoute() {
    context.read<TransactionsBloc>().add(const TransactionsStarted());
    context.read<CategoriesBloc>().add(CategoriesStarted(defaultCategories()));
    context.read<AccountsBloc>().add(const AccountsStarted());
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HomeBloc>().state;
    final locale = Localizations.localeOf(context).toString();
    final firstDay = context
        .watch<AppSettingBloc>()
        .state
        .appSetting
        .firstDayOfWeek;
    if (state.view == HomeView.summary) {
      return HomeSummaryView(
        figures: state.figures,
        transactions: state.transactions,
        categories: state.categories,
        accounts: state.accounts,
        locale: locale,
      );
    }
    return HomeCalendarView(
      month: state.month,
      days: state.days,
      dayItems: state.selectedTransactions,
      categories: state.categories,
      accounts: state.accounts,
      selectedDay: state.selectedDay,
      firstDayOfWeek: firstDay,
      locale: locale,
      onSelect: (day) => context.read<HomeBloc>().add(HomeDaySelected(day)),
    );
  }
}
