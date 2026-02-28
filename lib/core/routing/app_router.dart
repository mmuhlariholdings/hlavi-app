import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hlavi_app/core/routing/routes.dart';
import 'package:hlavi_app/features/agenda/presentation/screens/agenda_screen.dart';
import 'package:hlavi_app/features/auth/presentation/screens/login_screen.dart';
import 'package:hlavi_app/features/board/presentation/screens/board_screen.dart';
import 'package:hlavi_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:hlavi_app/features/timeline/presentation/screens/timeline_screen.dart';
import 'package:hlavi_app/shared/widgets/app_bottom_navigation.dart';

/// Application router configuration
/// Handles navigation and route guards
class AppRouter {
  /// Creates the router instance
  /// isAuthenticated callback is used to determine if user is logged in
  static GoRouter createRouter({required bool Function() isAuthenticated}) {
    return GoRouter(
      initialLocation: Routes.login,
      debugLogDiagnostics: true,
      routes: [
        // Auth Routes
        GoRoute(
          path: Routes.login,
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),

        // Main app shell with bottom navigation
        ShellRoute(
          builder: (context, state, child) {
            // Determine current index based on location
            final location = state.uri.path;
            int currentIndex = 0;
            if (location.startsWith('/board')) {
              currentIndex = 1;
            } else if (location.startsWith('/timeline')) {
              currentIndex = 2;
            } else if (location.startsWith('/agenda')) {
              currentIndex = 3;
            }

            return Scaffold(
              body: child,
              bottomNavigationBar: AppBottomNavigation(
                currentIndex: currentIndex,
              ),
            );
          },
          routes: [
            // Dashboard Route - Main dashboard with statistics and repo management
            GoRoute(
              path: Routes.dashboard,
              name: 'dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),

            // Board Route - Kanban board view
            GoRoute(
              path: Routes.board,
              name: 'board',
              builder: (context, state) => const BoardScreen(),
            ),

            // Timeline Route - Gantt chart timeline view
            GoRoute(
              path: Routes.timeline,
              name: 'timeline',
              builder: (context, state) => const TimelineScreen(),
            ),

            // Agenda Route - Date-filtered task view
            GoRoute(
              path: Routes.agenda,
              name: 'agenda',
              builder: (context, state) => const AgendaScreen(),
            ),
          ],
        ),

        // Task Detail Route (outside shell - no bottom nav)
        GoRoute(
          path: Routes.taskDetail,
          name: 'taskDetail',
          builder: (context, state) {
            final taskId = state.pathParameters['id'] ?? '';
            return _PlaceholderScreen(
              title: 'Task Detail',
              description: 'Task ID: $taskId',
            );
          },
        ),
      ],

      // Redirect logic based on authentication state
      redirect: (context, state) {
        final isLoggedIn = isAuthenticated();
        final isOnLoginPage = state.matchedLocation == Routes.login;

        // If not logged in and not on login page, redirect to login
        if (!isLoggedIn && !isOnLoginPage) {
          return Routes.login;
        }

        // If logged in and on login page, redirect to dashboard
        if (isLoggedIn && isOnLoginPage) {
          return Routes.dashboard;
        }

        // No redirect needed
        return null;
      },

      // Error page
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                state.uri.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(Routes.login),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder screen for routes not yet implemented
/// Used during development to show where features will be added
class _PlaceholderScreen extends StatelessWidget {

  const _PlaceholderScreen({
    required this.title,
    required this.description,
  });
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            Text(
              'Coming soon in Phase ${_getPhaseNumber(title)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPhaseNumber(String title) {
    switch (title) {
      case 'Dashboard':
      case 'Repositories':
        return '3';
      case 'Board':
        return '4';
      case 'Task Detail':
        return '5';
      case 'Timeline':
        return '6';
      case 'Agenda':
        return '7';
      default:
        return '?';
    }
  }
}
