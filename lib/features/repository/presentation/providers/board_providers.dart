import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_providers.dart';
import '../../data/datasources/board_remote_datasource.dart';
import '../../domain/entities/board_config.dart';
import 'repository_providers.dart';

/// Provider for board remote data source
final boardDataSourceProvider = Provider<BoardRemoteDataSource>((ref) {
  final apiClient = ref.watch(githubApiClientProvider);
  return BoardRemoteDataSource(apiClient);
});

/// Provider for fetching board configuration
/// Cached for 5 minutes per repo/branch combination
final boardConfigProvider = FutureProvider.family<BoardConfig, ({String owner, String repo, String? branch})>(
  (ref, params) async {
    // Keep alive for 5 minutes to cache results
    final link = ref.keepAlive();
    Timer(const Duration(minutes: 5), link.close);

    final dataSource = ref.watch(boardDataSourceProvider);
    return dataSource.getBoardConfig(
      params.owner,
      params.repo,
      branch: params.branch,
    );
  },
);

/// Convenience provider for getting board config for currently selected repo/branch
final currentBoardConfigProvider = FutureProvider<BoardConfig?>((ref) async {
  final selectedRepo = ref.watch(selectedRepositoryProvider);
  final selectedBranch = ref.watch(selectedBranchProvider);

  if (selectedRepo == null) {
    return null;
  }

  return ref.watch(
    boardConfigProvider((
      owner: selectedRepo.owner.login,
      repo: selectedRepo.name,
      branch: selectedBranch,
    )).future,
  );
});
