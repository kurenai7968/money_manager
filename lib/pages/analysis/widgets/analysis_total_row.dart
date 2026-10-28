import 'package:material_ui/material_ui.dart';

class AnalysisTotalRow extends StatelessWidget {
  const AnalysisTotalRow({
    required this.color,
    required this.title,
    required this.amount,
    this.share = '',
    super.key,
  });

  final Color color;
  final String title;
  final String amount;
  final String share;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.circle, color: color, size: 12),
      title: Text(title),
      trailing: Text(share.isEmpty ? amount : '$share  $amount'),
    );
  }
}
