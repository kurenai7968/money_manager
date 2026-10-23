import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_manager/widgets/app_tab_bar.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    required this.navigationShell,
    required this.onRecord,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final VoidCallback onRecord;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppTabBar(
        selectedIndex: navigationShell.currentIndex,
        onRecord: onRecord,
        onSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
