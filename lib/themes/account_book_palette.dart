import 'package:material_ui/material_ui.dart';
import 'package:money_manager/models/enums/account_book_color.dart';

abstract final class AccountBookPalette {
  static const coral = Color(0xFFC2410C);
  static const red = Color(0xFFB91C1C);
  static const blue = Color(0xFF1D4ED8);
  static const amber = Color(0xFFB45309);
  static const teal = Color(0xFF0F766E);
  static const pink = Color(0xFFBE185D);
  static const green = Color(0xFF0E7A42);
  static const slate = Color(0xFF3F4A57);

  static const colorKeys = [
    'coral',
    'red',
    'blue',
    'amber',
    'teal',
    'pink',
    'green',
    'slate',
  ];

  static const iconKeys = [
    'food',
    'transit',
    'housing',
    'shopping',
    'entertainment',
    'medical',
    'other',
    'salary',
    'bonus',
  ];

  static Color of(AccountBookColor color) {
    return switch (color) {
      AccountBookColor.coral => coral,
      AccountBookColor.red => red,
      AccountBookColor.blue => blue,
      AccountBookColor.amber => amber,
      AccountBookColor.teal => teal,
      AccountBookColor.pink => pink,
      AccountBookColor.green => green,
      AccountBookColor.slate => slate,
    };
  }

  static Color directionColor({
    required bool income,
    AccountBookColor incomeColor = AccountBookColor.green,
    AccountBookColor expenseColor = AccountBookColor.red,
  }) {
    return of(income ? incomeColor : expenseColor);
  }

  static Color color(String key) {
    for (final color in AccountBookColor.values) {
      if (color.name == key) {
        return of(color);
      }
    }
    return coral;
  }

  static IconData icon(String key) {
    return switch (key) {
      'food' => Icons.restaurant_outlined,
      'transit' => Icons.directions_transit_outlined,
      'housing' => Icons.home_outlined,
      'shopping' => Icons.shopping_bag_outlined,
      'entertainment' => Icons.confirmation_number_outlined,
      'medical' => Icons.medical_services_outlined,
      'salary' => Icons.work_outline,
      'bonus' => Icons.card_giftcard_outlined,
      _ => Icons.circle_outlined,
    };
  }
}
