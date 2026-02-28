import 'package:dio/dio.dart';

import '../../features/repository/domain/entities/repository.dart';
import '../../features/tasks/domain/entities/task.dart';
import 'models/github_content.dart';

/// GitHub API client using Dio directly
/// Provides type-safe methods for GitHub API endpoints
class GithubApiClient {

  GithubApiClient(this._dio);
  final Dio _dio;

  /// Get authenticated user's repositories
  Future<List<Repository>> getRepositories({
    String sort = 'updated',
    int perPage = 100,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/user/repos',
      queryParameters: {
        'sort': sort,
        'per_page': perPage,
      },
    );

    return (response.data as List)
        .map((json) => Repository.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get repository branches
  Future<List<Map<String, dynamic>>> getBranches(
    String owner,
    String repo, {
    int perPage = 100,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/repos/$owner/$repo/branches',
      queryParameters: {
        'per_page': perPage,
      },
    );

    return (response.data as List).cast<Map<String, dynamic>>();
  }

  /// Get repository information including default branch
  Future<Map<String, dynamic>> getRepository(
    String owner,
    String repo,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/repos/$owner/$repo',
    );

    return response.data!;
  }

  /// Check if .hlavi directory exists
  Future<List<Map<String, dynamic>>> checkHlaviDirectory(
    String owner,
    String repo, {
    String? ref,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/repos/$owner/$repo/contents/.hlavi',
      queryParameters: ref != null ? {'ref': ref} : null,
    );

    return (response.data as List).cast<Map<String, dynamic>>();
  }

  /// Get task files from .hlavi/tasks directory
  Future<List<GithubContent>> getTaskFiles(
    String owner,
    String repo, {
    String? ref,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/repos/$owner/$repo/contents/.hlavi/tasks',
      queryParameters: ref != null ? {'ref': ref} : null,
    );

    return (response.data as List)
        .map((json) => GithubContent.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get file content from repository
  Future<GithubContent> getFileContent(
    String owner,
    String repo,
    String path, {
    String? ref,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/repos/$owner/$repo/contents/$path',
      queryParameters: ref != null ? {'ref': ref} : null,
    );

    return GithubContent.fromJson(response.data!);
  }

  /// Create or update file in repository
  Future<Map<String, dynamic>> createOrUpdateFile(
    String owner,
    String repo,
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/repos/$owner/$repo/contents/$path',
      data: body,
    );

    return response.data!;
  }

  /// Get authenticated user information
  Future<Map<String, dynamic>> getUserInfo() async {
    final response = await _dio.get<Map<String, dynamic>>('/user');
    return response.data!;
  }
}
