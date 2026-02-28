import 'dart:convert';

import '../../../../core/api/github_api_client.dart';
import '../../domain/entities/task.dart';

/// Remote data source for task operations
/// Fetches and updates task data from GitHub repository
class TaskRemoteDataSource {
  TaskRemoteDataSource(this._apiClient);

  final GithubApiClient _apiClient;

  /// Get all tasks from repository
  Future<List<Task>> getTasks(
    String owner,
    String repo, {
    String? branch,
  }) async {
    try {
      // Get all task files from .hlavi/tasks directory
      final taskFiles = await _apiClient.getTaskFiles(
        owner,
        repo,
        ref: branch,
      );

      // Filter to only JSON files
      final jsonFiles = taskFiles.where((file) => file.name.endsWith('.json')).toList();

      // Fetch all task files in parallel for much better performance
      final taskFutures = jsonFiles.map((file) async {
        try {
          final content = await _apiClient.getFileContent(
            owner,
            repo,
            file.path,
            ref: branch,
          );

          // Decode base64 content
          if (content.content == null) {
            return null;
          }

          // Remove whitespace from base64 string (GitHub API adds newlines/spaces)
          final cleanedContent = content.content!.replaceAll(RegExp(r'\s'), '');
          final decoded = utf8.decode(base64.decode(cleanedContent));
          final json = jsonDecode(decoded) as Map<String, dynamic>;

          return Task.fromJson(json);
        } catch (e) {
          // Skip malformed task files
          return null;
        }
      }).toList();

      // Wait for all fetches to complete in parallel
      final results = await Future.wait(taskFutures);

      // Filter out nulls (failed fetches) and return
      return results.whereType<Task>().toList();
    } catch (e) {
      // If .hlavi/tasks doesn't exist, return empty list
      if (e.toString().contains('404')) {
        return [];
      }
      rethrow;
    }
  }

  /// Get a single task by ID
  Future<Task?> getTask(
    String owner,
    String repo,
    String taskId, {
    String? branch,
  }) async {
    try {
      final content = await _apiClient.getFileContent(
        owner,
        repo,
        '.hlavi/tasks/$taskId.json',
        ref: branch,
      );

      // Decode base64 content
      if (content.content == null) {
        return null;
      }

      // Remove whitespace from base64 string (GitHub API adds newlines/spaces)
      final cleanedContent = content.content!.replaceAll(RegExp(r'\s'), '');
      final decoded = utf8.decode(base64.decode(cleanedContent));
      final json = jsonDecode(decoded) as Map<String, dynamic>;

      return Task.fromJson(json);
    } catch (e) {
      if (e.toString().contains('404')) {
        return null;
      }
      rethrow;
    }
  }

  /// Create or update a task
  Future<void> saveTask(
    String owner,
    String repo,
    Task task, {
    String? branch,
    String? commitMessage,
  }) async {
    final path = '.hlavi/tasks/${task.id}.json';

    // Get current file SHA if it exists (required for updates)
    String? sha;
    try {
      final existing = await _apiClient.getFileContent(
        owner,
        repo,
        path,
        ref: branch,
      );
      sha = existing.sha;
    } catch (e) {
      // File doesn't exist, SHA not needed for creation
    }

    // Encode task as base64
    final content = base64.encode(
      utf8.encode(
        jsonEncode(task.toJson()),
      ),
    );

    final body = {
      'message': commitMessage ?? 'Update task ${task.id}',
      'content': content,
      if (sha != null) 'sha': sha,
      if (branch != null) 'branch': branch,
    };

    await _apiClient.createOrUpdateFile(owner, repo, path, body);
  }

  /// Delete a task
  Future<void> deleteTask(
    String owner,
    String repo,
    String taskId, {
    String? branch,
    String? commitMessage,
  }) async {
    final path = '.hlavi/tasks/$taskId.json';

    // Get current file SHA (required for deletion)
    final existing = await _apiClient.getFileContent(
      owner,
      repo,
      path,
      ref: branch,
    );

    final body = {
      'message': commitMessage ?? 'Delete task $taskId',
      'sha': existing.sha,
      if (branch != null) 'branch': branch,
    };

    await _apiClient.createOrUpdateFile(owner, repo, path, body);
  }
}
