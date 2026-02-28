import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration for the application
/// Loads values from .env file
class EnvConfig {
  /// GitHub OAuth Client ID
  /// This is safe to be public - it just identifies your app
  static String get githubClientId => dotenv.env['GITHUB_CLIENT_ID'] ?? '';

  /// GitHub OAuth Client Secret
  /// Required for traditional OAuth Apps (stored in APK, less secure)
  static String get githubClientSecret =>
      dotenv.env['GITHUB_CLIENT_SECRET'] ?? '';

  /// GitHub OAuth Redirect URI
  static String get githubRedirectUri =>
      dotenv.env['GITHUB_REDIRECT_URI'] ?? 'app.hlavi://oauth-callback';

  /// Check if all required environment variables are set
  static bool get isConfigured =>
      githubClientId.isNotEmpty && githubClientSecret.isNotEmpty;
}
