import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:money_manager/themes/ledger_palette.dart';

class HomeMonthDonut extends StatelessWidget {
  const HomeMonthDonut({
    required this.income,
    required this.expense,
    required this.label,
    required this.amount,
    super.key,
  });

  final int income;
  final int expense;
  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: CustomPaint(
        painter: _DonutPainter(
          income: income,
          expense: expense,
          incomeColor: LedgerPalette.green,
          expenseColor: Theme.of(context).colorScheme.primary,
          trackColor: Theme.of(context).colorScheme.outline,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(amount, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.income,
    required this.expense,
    required this.incomeColor,
    required this.expenseColor,
    required this.trackColor,
  });

  final int income;
  final int expense;
  final Color incomeColor;
  final Color expenseColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.butt;
    final center = rect.center;
    final radius = size.shortestSide / 2 - 16;
    final arc = Rect.fromCircle(center: center, radius: radius);
    final total = income + expense;
    if (total == 0) {
      paint.color = trackColor;
      canvas.drawCircle(center, radius, paint);
      return;
    }
    final incomeSweep = (income / total) * math.pi * 2;
    paint.color = incomeColor;
    canvas.drawArc(arc, -math.pi / 2, incomeSweep, false, paint);
    paint.color = expenseColor;
    canvas.drawArc(
      arc,
      -math.pi / 2 + incomeSweep,
      math.pi * 2 - incomeSweep,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.income != income || oldDelegate.expense != expense;
  }
}
