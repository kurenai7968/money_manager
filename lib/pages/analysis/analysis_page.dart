import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/pages/analysis/bloc/analysis_bloc.dart';
import 'package:money_manager/pages/analysis/bloc/analysis_event.dart';
import 'package:money_manager/pages/analysis/widgets/analysis_app_bar.dart';
import 'package:money_manager/pages/analysis/widgets/analysis_body.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnalysisBloc(
        accounts: context.read(),
        transactions: context.read(),
        categories: context.read(),
      )..add(const AnalysisStarted()),
      child: const Scaffold(appBar: AnalysisAppBar(), body: AnalysisBody()),
    );
  }
}
