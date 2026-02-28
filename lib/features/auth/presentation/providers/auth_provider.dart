import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hlavi_app/features/auth/data/datasources/github_auth_datasource.dart';
import 'package:hlavi_app/features/auth/data/models/auth_token.dart';
import 'package:hlavi_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:hlavi_app/features/auth/domain/repositories/auth_repository.dart';

/// Provider for GithubAuthDataSource
final githubAuthDataSourceProvider = Provider<GithubAuthDataSource>((ref) {
  return GithubAuthDataSource();
});

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(githubAuthDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
});

/// Auth state notifier provider
/// Manages authentication state throughout the app
final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthStateNotifier(repository);
});

/// Auth state notifier class
/// Handles sign in, sign out, and session restoration
class AuthStateNotifier extends StateNotifier<AuthState> {

  AuthStateNotifier(this._repository) : super(AuthState.initial()) {
    _checkAuthStatus();
  }
  final AuthRepository _repository;

  /// Check if user has a stored token on app launch
  Future<void> _checkAuthStatus() async {
    state = AuthState.loading();

    try {
      final hasToken = await _repository.hasValidToken();

      if (hasToken) {
        final token = await _repository.getStoredToken();
        if (token != null) {
          // Fetch user info
          final user = await _repository.getUserInfo(token.accessToken);
          state = AuthState.authenticated(token: token, user: user);
        } else {
          state = AuthState.initial();
        }
      } else {
        state = AuthState.initial();
      }
    } catch (e) {
      state = AuthState.error('Failed to restore session: $e');
    }
  }

  /// Sign in with GitHub OAuth
  Future<void> signIn() async {
    state = AuthState.loading();

    try {
      final token = await _repository.signIn();
      final user = await _repository.getUserInfo(token.accessToken);

      state = AuthState.authenticated(token: token, user: user);
    } catch (e) {
      state = AuthState.error('Sign in failed: $e');
    }
  }

  /// Sign out and clear stored credentials
  Future<void> signOut() async {
    state = AuthState.loading();

    try {
      await _repository.signOut();
      state = AuthState.initial();
    } catch (e) {
      state = AuthState.error('Sign out failed: $e');
      // Still set to initial state even if sign out fails
      state = AuthState.initial();
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}
