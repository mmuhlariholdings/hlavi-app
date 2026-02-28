import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom navigation bar for the app
/// Provides navigation between Dashboard, Board, and Agenda views
class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    required this.currentIndex,
    super.key,
  });

  final int currentIndex;

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/agenda');
        break;
      case 2:
        context.go('/board');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) => _onTap(context, index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_today_outlined),
          selectedIcon: Icon(Icons.calendar_today),
          label: 'Agenda',
        ),
        NavigationDestination(
          icon: Icon(Icons.view_column_outlined),
          selectedIcon: Icon(Icons.view_column),
          label: 'Board',
        ),
      ],
    );
  }
}
