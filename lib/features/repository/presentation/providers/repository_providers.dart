import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_providers.dart';
import '../../data/datasources/repository_remote_datasource.dart';
import '../../domain/entities/repository.dart';

/// Provider for repository remote data source
final repositoryDataSourceProvider = Provider<RepositoryRemoteDataSource>((ref) {
  final apiClient = ref.watch(githubApiClientProvider);
  return RepositoryRemoteDataSource(apiClient);
});

/// Provider for fetching user's repositories
/// Auto-refreshes when auth state changes
final repositoriesProvider = FutureProvider<List<Repository>>((ref) async {
  final dataSource = ref.watch(repositoryDataSourceProvider);
  return dataSource.getRepositories();
});

/// Provider for fetching branches of a specific repository
/// Takes owner and repo as parameters
final branchesProvider = FutureProvider.family<List<String>, ({String owner, String repo})>(
  (ref, params) async {
    final dataSource = ref.watch(repositoryDataSourceProvider);
    return dataSource.getBranches(params.owner, params.repo);
  },
);

/// Provider for checking if a repository has .hlavi directory
final hasHlaviDirectoryProvider = FutureProvider.family<bool, ({String owner, String repo, String? branch})>(
  (ref, params) async {
    final dataSource = ref.watch(repositoryDataSourceProvider);
    return dataSource.hasHlaviDirectory(
      params.owner,
      params.repo,
      branch: params.branch,
    );
  },
);

/// State provider for selected repository
/// Persists user's repository selection
final selectedRepositoryProvider = StateProvider<Repository?>((ref) => null);

/// State provider for selected branch
/// Persists user's branch selection
final selectedBranchProvider = StateProvider<String?>((ref) => null);
