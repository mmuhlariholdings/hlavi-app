import 'package:hlavi_app/features/auth/data/models/auth_token.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Sign in with GitHub OAuth
  Future<AuthToken> signIn();

  /// Sign out and clear stored credentials
  Future<void> signOut();

  /// Get stored authentication token if available
  Future<AuthToken?> getStoredToken();

  /// Fetch authenticated user information from GitHub
  Future<AuthUser> getUserInfo(String accessToken);

  /// Check if a valid token is stored
  Future<bool> hasValidToken();
}
