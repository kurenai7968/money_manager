import 'package:material_ui/material_ui.dart';

class AnalysisMonthBars extends StatelessWidget {
  final List<DateTime> months;
  final List<double> values;
  final double maxValue;

  const AnalysisMonthBars({
    required this.months,
    required this.values,
    required this.maxValue,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var index = 0; index < months.length; index++)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: values[index] / maxValue,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: index == months.length - 1
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text('${months[index].month}'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
