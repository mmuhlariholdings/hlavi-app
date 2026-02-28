import '../../../../core/api/github_api_client.dart';
import '../../domain/entities/repository.dart';

/// Remote data source for repository operations
/// Fetches repository and branch data from GitHub API
class RepositoryRemoteDataSource {
  RepositoryRemoteDataSource(this._apiClient);

  final GithubApiClient _apiClient;

  /// Get authenticated user's repositories
  Future<List<Repository>> getRepositories() {
    return _apiClient.getRepositories(
      sort: 'updated', // Most recently updated first
      perPage: 100,
    );
  }

  /// Get branches for a specific repository
  Future<List<String>> getBranches(String owner, String repo) async {
    final branches = await _apiClient.getBranches(owner, repo, perPage: 100);
    return branches
        .map((branch) => branch['name'] as String)
        .toList();
  }

  /// Get repository information including default branch
  Future<Repository> getRepository(String owner, String repo) async {
    final data = await _apiClient.getRepository(owner, repo);
    return Repository.fromJson(data);
  }

  /// Check if .hlavi directory exists in repository
  Future<bool> hasHlaviDirectory(
    String owner,
    String repo, {
    String? branch,
  }) async {
    try {
      await _apiClient.checkHlaviDirectory(
        owner,
        repo,
        ref: branch,
      );
      return true;
    } catch (e) {
      // 404 error means directory doesn't exist
      return false;
    }
  }
}
