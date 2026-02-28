import 'dart:async';

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
/// Cached for 5 minutes to reduce API calls
final repositoriesProvider = FutureProvider<List<Repository>>((ref) async {
  // Keep alive for 5 minutes to cache results
  final link = ref.keepAlive();
  Timer(const Duration(minutes: 5), link.close);

  final dataSource = ref.watch(repositoryDataSourceProvider);
  final repositories = await dataSource.getRepositories();

  // Sort alphabetically by organization name first, then by repository name
  repositories.sort((a, b) {
    final ownerComparison = a.owner.login.toLowerCase().compareTo(b.owner.login.toLowerCase());
    if (ownerComparison != 0) {
      return ownerComparison;
    }
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });

  return repositories;
});

/// Provider for fetching branches of a specific repository
/// Takes owner and repo as parameters
/// Cached for 5 minutes per repository
final branchesProvider = FutureProvider.family<List<String>, ({String owner, String repo})>(
  (ref, params) async {
    // Keep alive for 5 minutes to cache results
    final link = ref.keepAlive();
    Timer(const Duration(minutes: 5), link.close);

    final dataSource = ref.watch(repositoryDataSourceProvider);
    final branches = await dataSource.getBranches(params.owner, params.repo);

    // Sort branches alphabetically (case-insensitive)
    branches.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return branches;
  },
);

/// Provider for checking if a repository has .hlavi directory
/// Cached for 5 minutes per repo/branch combination
final hasHlaviDirectoryProvider = FutureProvider.family<bool, ({String owner, String repo, String? branch})>(
  (ref, params) async {
    // Keep alive for 5 minutes to cache results
    final link = ref.keepAlive();
    Timer(const Duration(minutes: 5), link.close);

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
