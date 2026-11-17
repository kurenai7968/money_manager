import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_bloc.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_state.dart';
import 'package:money_manager/models/enums/first_day_of_week.dart';
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
    final locale = Localizations.localeOf(context).toString();
    const listPadding = EdgeInsets.only(bottom: HomeRecordButton.listClearance);
    return BlocSelector<AppSettingBloc, AppSettingState, FirstDayOfWeek>(
      selector: (state) => state.appSetting.firstDayOfWeek,
      builder: (context, firstDay) {
        return BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (previous, current) =>
              previous.view != current.view ||
              previous.month != current.month ||
              previous.selectedDay != current.selectedDay ||
              previous.figures != current.figures ||
              previous.days != current.days ||
              previous.transactions != current.transactions ||
              previous.categories != current.categories ||
              previous.accounts != current.accounts,
          builder: (context, state) {
            void reload() {
              context.read<HomeBloc>().add(const HomeInitialized());
            }

            if (state.view == HomeView.summary) {
              return HomeSummaryView(
                figures: state.figures,
                days: state.days,
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
              categories: state.categories,
              accounts: state.accounts,
              selectedDay: state.selectedDay,
              firstDayOfWeek: firstDay,
              locale: locale,
              onSelect: (day) =>
                  context.read<HomeBloc>().add(HomeDaySelected(day)),
              listPadding: listPadding,
              onRecordReturned: reload,
            );
          },
        );
      },
    );
  }
}
