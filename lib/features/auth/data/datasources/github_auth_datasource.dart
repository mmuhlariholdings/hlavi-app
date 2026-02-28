import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/config/env_config.dart';
import '../models/auth_token.dart';

/// Data source for GitHub OAuth authentication
/// Handles the OAuth flow using flutter_appauth and stores tokens securely
class GithubAuthDataSource {

  GithubAuthDataSource({
    FlutterAppAuth? appAuth,
    FlutterSecureStorage? secureStorage,
  })  : _appAuth = appAuth ?? const FlutterAppAuth(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();
  final FlutterAppAuth _appAuth;
  final FlutterSecureStorage _secureStorage;

  // GitHub OAuth endpoints
  static const String _authorizationEndpoint =
      'https://github.com/login/oauth/authorize';
  static const String _tokenEndpoint =
      'https://github.com/login/oauth/access_token';
  static const String _userInfoEndpoint = 'https://api.github.com/user';

  // OAuth scopes (matching web app)
  static const List<String> _scopes = [
    'repo', // Full access to repositories
    'read:user', // Read user profile information
    'user:email', // Access user email addresses
  ];

  // Secure storage keys
  static const String _accessTokenKey = 'github_access_token';
  static const String _tokenTypeKey = 'github_token_type';

  /// Sign in with GitHub OAuth
  /// Returns an AuthToken on success, throws an exception on failure
  Future<AuthToken> signIn() async {
    // flutter_appauth doesn't support web
    if (kIsWeb) {
      throw Exception(
        'GitHub OAuth is not supported on web platform. '
        'Please run the app on iOS or Android to test authentication.',
      );
    }

    try {
      // SECURITY: Not providing clientSecret makes flutter_appauth use PKCE
      // (Proof Key for Code Exchange), which is the secure standard for mobile apps.
      // PKCE generates a dynamic code_verifier instead of using a static secret.
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          EnvConfig.githubClientId,
          EnvConfig.githubRedirectUri,
          // No clientSecret = PKCE is automatically used
          serviceConfiguration: const AuthorizationServiceConfiguration(
            authorizationEndpoint: _authorizationEndpoint,
            tokenEndpoint: _tokenEndpoint,
          ),
          scopes: _scopes,
        ),
      );

      if (result == null) {
        throw Exception('Authentication cancelled by user');
      }

      if (result.accessToken == null) {
        throw Exception('No access token received from GitHub');
      }

      final token = AuthToken(
        accessToken: result.accessToken!,
        tokenType: result.tokenType ?? 'Bearer',
        scope: result.accessTokenExpirationDateTime != null
            ? _scopes.join(' ')
            : null,
      );

      // Store token securely
      await _storeToken(token);

      return token;
    } catch (e) {
      throw Exception('GitHub OAuth failed: $e');
    }
  }

  /// Get stored authentication token
  /// Returns null if no token is stored
  Future<AuthToken?> getStoredToken() async {
    try {
      final accessToken = await _secureStorage.read(key: _accessTokenKey);
      final tokenType = await _secureStorage.read(key: _tokenTypeKey);

      if (accessToken == null) {
        return null;
      }

      return AuthToken(
        accessToken: accessToken,
        tokenType: tokenType ?? 'Bearer',
      );
    } catch (e) {
      return null;
    }
  }

  /// Store authentication token securely
  Future<void> _storeToken(AuthToken token) async {
    await _secureStorage.write(
      key: _accessTokenKey,
      value: token.accessToken,
    );
    await _secureStorage.write(
      key: _tokenTypeKey,
      value: token.tokenType,
    );
  }

  /// Clear stored authentication token
  Future<void> signOut() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _tokenTypeKey);
  }

  /// Check if user is authenticated (has a stored token)
  Future<bool> isAuthenticated() async {
    final token = await getStoredToken();
    return token != null;
  }

  /// Fetch authenticated user information from GitHub API
  Future<AuthUser> getUserInfo(String accessToken) async {
    try {
      final dio = Dio();
      final response = await dio.get<Map<String, dynamic>>(
        _userInfoEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2022-11-28',
          },
        ),
      );

      return AuthUser.fromJson(response.data!);
    } catch (e) {
      throw Exception('Failed to fetch user info from GitHub: $e');
    }
  }
}
