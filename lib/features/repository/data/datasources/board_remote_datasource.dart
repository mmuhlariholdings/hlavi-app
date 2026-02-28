import 'dart:convert';

import '../../../../core/api/github_api_client.dart';
import '../../../tasks/domain/entities/task_status.dart';
import '../../domain/entities/board_config.dart';

/// Remote data source for board configuration
/// Fetches board.json from .hlavi directory
class BoardRemoteDataSource {
  BoardRemoteDataSource(this._apiClient);

  final GithubApiClient _apiClient;

  /// Get board configuration from repository
  Future<BoardConfig> getBoardConfig(
    String owner,
    String repo, {
    String? branch,
  }) async {
    try {
      final content = await _apiClient.getFileContent(
        owner,
        repo,
        '.hlavi/board.json',
        ref: branch,
      );

      // Decode base64 content
      if (content.content == null) {
        // Return default config if file doesn't exist
        return _defaultBoardConfig();
      }

      // Remove whitespace from base64 string (GitHub API adds newlines/spaces)
      final cleanedContent = content.content!.replaceAll(RegExp(r'\s'), '');
      final decoded = utf8.decode(base64.decode(cleanedContent));
      final json = jsonDecode(decoded) as Map<String, dynamic>;

      final config = BoardConfig.fromJson(json);

      // If columns is empty, return default config
      if (config.columns.isEmpty) {
        return _defaultBoardConfig();
      }

      return config;
    } catch (e) {
      // If .hlavi/board.json doesn't exist or is malformed, return default config
      if (e.toString().contains('404') ||
          e.toString().contains('FormatException') ||
          e.toString().contains('type') ||
          e.toString().contains('Null')) {
        return _defaultBoardConfig();
      }
      rethrow;
    }
  }

  /// Default board configuration matching web app defaults
  BoardConfig _defaultBoardConfig() {
    return const BoardConfig(
      columns: [
        BoardColumn(
          name: 'New',
          status: TaskStatus.newStatus,
          agentEnabled: false,
        ),
        BoardColumn(
          name: 'Open',
          status: TaskStatus.open,
          agentEnabled: false,
        ),
        BoardColumn(
          name: 'In Progress',
          status: TaskStatus.inProgress,
          agentEnabled: false,
        ),
        BoardColumn(
          name: 'Pending',
          status: TaskStatus.pending,
          agentEnabled: false,
        ),
        BoardColumn(
          name: 'Review',
          status: TaskStatus.review,
          agentEnabled: false,
        ),
        BoardColumn(
          name: 'Done',
          status: TaskStatus.done,
          agentEnabled: false,
        ),
      ],
      name: 'Default Board',
    );
  }
}
