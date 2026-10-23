import 'package:flutter/material.dart';
import 'package:money_manager/core/extensions/context_extension.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(context.l10n.analysis)));
  }
}
