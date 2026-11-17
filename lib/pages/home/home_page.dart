import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_bloc.dart';
import 'package:money_manager/pages/home/bloc/home_bloc.dart';
import 'package:money_manager/pages/home/bloc/home_event.dart';
import 'package:money_manager/pages/home/bloc/home_state.dart';
import 'package:money_manager/pages/home/widgets/home_app_bar.dart';
import 'package:money_manager/pages/home/widgets/home_calendar_view.dart';
import 'package:money_manager/pages/home/widgets/home_record_button.dart';
import 'package:money_manager/pages/home/widgets/home_summary_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HomeBloc(accountBookService: context.read())
            ..add(const HomeInitialized()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final firstDay = context.select(
      (AppSettingBloc bloc) => bloc.state.appSetting.firstDayOfWeek,
    );
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final bloc = context.read<HomeBloc>();
        void reload() => bloc.add(const HomeInitialized());
        final locale = Localizations.localeOf(context).toString();
        const listPadding = EdgeInsets.only(
          bottom: HomeRecordButton.listClearance,
        );
        return Scaffold(
          appBar: HomeAppBar(
            accounts: state.accounts,
            selectedAccountId: state.selectedAccountId,
            month: state.month,
            view: state.view,
            onAccountSelected: (id) => bloc.add(HomeAccountSelected(id)),
            onMonthShifted: (delta) => bloc.add(HomeMonthShifted(delta)),
            onMonthSelected: (month) => bloc.add(HomeMonthSelected(month)),
            onViewToggled: () => bloc.add(const HomeViewToggled()),
          ),
          body: state.view == HomeView.summary
              ? HomeSummaryView(
                  income: state.income,
                  expense: state.expense,
                  balance: state.balance,
                  days: state.days,
                  categories: state.categories,
                  accounts: state.accounts,
                  locale: locale,
                  listPadding: listPadding,
                  onRecordReturned: reload,
                )
              : HomeCalendarView(
                  month: state.month,
                  days: state.days,
                  categories: state.categories,
                  accounts: state.accounts,
                  selectedDay: state.selectedDay,
                  firstDayOfWeek: firstDay,
                  locale: locale,
                  onSelect: (day) => bloc.add(HomeDaySelected(day)),
                  listPadding: listPadding,
                  onRecordReturned: reload,
                ),
          floatingActionButton: HomeRecordButton(onReturned: reload),
        );
      },
    );
  }
}
