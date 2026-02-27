import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

/// Root widget of the Hlavi application
class HlaviApp extends ConsumerWidget {
  const HlaviApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch auth state to determine if user is authenticated
    final authState = ref.watch(authStateProvider);

    // Create router with authentication check
    final router = AppRouter.createRouter(
      isAuthenticated: () => authState.isAuthenticated,
    );

    return MaterialApp.router(
      title: 'Hlavi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
