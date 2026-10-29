import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_bloc.dart';
import 'package:money_manager/core/utils/ledger_balance.dart';
import 'package:money_manager/models/category_defaults.dart';
import 'package:money_manager/pages/categories/bloc/categories_bloc.dart';
import 'package:money_manager/pages/categories/bloc/categories_event.dart';
import 'package:money_manager/pages/home/widgets/home_calendar_view.dart';
import 'package:money_manager/pages/home/widgets/home_frame.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    final frame = HomeFrame.of(context);
    final locale = Localizations.localeOf(context).toString();
    final transactions = context.watch<TransactionsBloc>().state.transactions;
    final categories = context.watch<CategoriesBloc>().state.categories;
    final inMonth = transactions
        .where(
          (item) =>
              item.date.year == frame.month.year &&
              item.date.month == frame.month.month,
        )
        .toList();
    final weekStart = context
        .watch<AppSettingBloc>()
        .state
        .appSetting
        .weekStart;
    final figures = monthFigures(transactions, frame.month);
    if (frame.view == HomeView.summary) {
      return HomeSummaryView(
        figures: figures,
        transactions: inMonth,
        categories: categories,
        locale: locale,
      );
    }
    return HomeCalendarView(
      month: frame.month,
      transactions: inMonth,
      categories: categories,
      selectedDay: frame.selectedDay,
      weekStart: weekStart,
      locale: locale,
      onSelect: frame.selectDay,
    );
  }
}
