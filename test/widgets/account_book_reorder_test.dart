import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/widgets/ledger_reorder.dart';

void main() {
  test('keeps a drag order until the saved list matches it', () {
    const dragged = ['transit', 'food'];
    const previous = ['food', 'transit'];

    expect(syncReorder(dragged, previous, (id) => id), dragged);
    expect(syncReorder(dragged, dragged, (id) => id), dragged);
    expect(
      syncReorder(dragged, const ['food', 'transit', 'salary'], (id) => id),
      ['food', 'transit', 'salary'],
    );
  });
}
