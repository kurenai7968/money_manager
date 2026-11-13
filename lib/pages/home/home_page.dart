import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/pages/home/bloc/home_bloc.dart';
import 'package:money_manager/pages/home/bloc/home_event.dart';
import 'package:money_manager/pages/home/widgets/home_app_bar.dart';
import 'package:money_manager/pages/home/widgets/home_body.dart';
import 'package:money_manager/pages/home/widgets/home_record_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HomeBloc(accountBookService: context.read())
            ..add(const HomeInitialized()),
      child: const Scaffold(
        appBar: HomeAppBar(),
        body: HomeBody(),
        floatingActionButton: HomeRecordButton(),
      ),
    );
  }
}
