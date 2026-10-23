import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecordPage extends StatelessWidget {
  const RecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final title = DateFormat.yMMMd(locale).format(DateTime.now());

    return Scaffold(appBar: AppBar(title: Text(title)));
  }
}
