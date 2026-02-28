import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_token.freezed.dart';
part 'auth_token.g.dart';

/// Authentication token from GitHub OAuth
@freezed
class AuthToken with _$AuthToken {
  const factory AuthToken({
    /// GitHub access token
    @JsonKey(name: 'access_token') required String accessToken,

    /// Token type (usually "Bearer")
    @JsonKey(name: 'token_type') required String tokenType,

    /// OAuth scopes granted
    String? scope,
  }) = _AuthToken;

  factory AuthToken.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenFromJson(json);
}

/// Authenticated user information
@freezed
class AuthUser with _$AuthUser {
  const factory AuthUser({
    /// GitHub user ID
    required int id,

    /// GitHub username/login
    required String login,

    /// User's avatar URL
    @JsonKey(name: 'avatar_url') required String avatarUrl, /// User's display name
    String? name,

    /// User's email address
    String? email,
  }) = _AuthUser;

  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      _$AuthUserFromJson(json);
}

/// Complete authentication state
@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    /// Whether the user is authenticated
    required bool isAuthenticated, /// Authentication token
    AuthToken? token,

    /// Authenticated user information
    AuthUser? user,

    /// Loading state
    @Default(false) bool isLoading,

    /// Error message if authentication failed
    String? error,
  }) = _AuthState;

  factory AuthState.fromJson(Map<String, dynamic> json) =>
      _$AuthStateFromJson(json);

  /// Initial unauthenticated state
  factory AuthState.initial() => const AuthState(
        isAuthenticated: false,
        isLoading: false,
      );

  /// Loading state
  factory AuthState.loading() => const AuthState(
        isAuthenticated: false,
        isLoading: true,
      );

  /// Authenticated state
  factory AuthState.authenticated({
    required AuthToken token,
    required AuthUser user,
  }) =>
      AuthState(
        token: token,
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );

  /// Error state
  factory AuthState.error(String message) => AuthState(
        isAuthenticated: false,
        isLoading: false,
        error: message,
      );
}
