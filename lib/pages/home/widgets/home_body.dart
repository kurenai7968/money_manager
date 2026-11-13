import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_bloc.dart';
import 'package:money_manager/pages/home/bloc/home_bloc.dart';
import 'package:money_manager/pages/home/bloc/home_event.dart';
import 'package:money_manager/pages/home/bloc/home_state.dart';
import 'package:money_manager/pages/home/widgets/home_calendar_view.dart';
import 'package:money_manager/pages/home/widgets/home_record_button.dart';
import 'package:money_manager/pages/home/widgets/home_summary_view.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HomeBloc>().state;
    final locale = Localizations.localeOf(context).toString();
    final firstDay = context
        .watch<AppSettingBloc>()
        .state
        .appSetting
        .firstDayOfWeek;
    const listPadding = EdgeInsets.only(bottom: HomeRecordButton.listClearance);
    void reload() {
      context.read<HomeBloc>().add(const HomeInitialized());
    }

    if (state.view == HomeView.summary) {
      return HomeSummaryView(
        figures: state.figures,
        transactions: state.transactions,
        categories: state.categories,
        accounts: state.accounts,
        locale: locale,
        listPadding: listPadding,
        onRecordReturned: reload,
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
      listPadding: listPadding,
      onRecordReturned: reload,
    );
  }
}
