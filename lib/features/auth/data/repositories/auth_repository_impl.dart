import 'package:hlavi_app/features/auth/data/datasources/github_auth_datasource.dart';
import 'package:hlavi_app/features/auth/data/models/auth_token.dart';
import 'package:hlavi_app/features/auth/domain/repositories/auth_repository.dart';

/// Implementation of AuthRepository using GithubAuthDataSource
class AuthRepositoryImpl implements AuthRepository {

  AuthRepositoryImpl(this._dataSource);
  final GithubAuthDataSource _dataSource;

  @override
  Future<AuthToken> signIn() async {
    try {
      return await _dataSource.signIn();
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _dataSource.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  @override
  Future<AuthToken?> getStoredToken() async {
    try {
      return await _dataSource.getStoredToken();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AuthUser> getUserInfo(String accessToken) async {
    try {
      return await _dataSource.getUserInfo(accessToken);
    } catch (e) {
      throw Exception('Failed to get user info: $e');
    }
  }

  @override
  Future<bool> hasValidToken() async {
    final token = await getStoredToken();
    return token != null;
  }
}
