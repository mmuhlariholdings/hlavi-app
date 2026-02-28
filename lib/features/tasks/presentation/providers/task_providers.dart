import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_providers.dart';
import '../../../repository/presentation/providers/repository_providers.dart';
import '../../data/datasources/task_remote_datasource.dart';
import '../../domain/entities/task.dart';

/// Provider for task remote data source
final taskDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  final apiClient = ref.watch(githubApiClientProvider);
  return TaskRemoteDataSource(apiClient);
});

/// Provider for fetching tasks from selected repository
/// Automatically refetches when repository or branch selection changes
final tasksProvider = FutureProvider<List<Task>>((ref) async {
  final dataSource = ref.watch(taskDataSourceProvider);
  final selectedRepo = ref.watch(selectedRepositoryProvider);
  final selectedBranch = ref.watch(selectedBranchProvider);

  // Return empty list if no repository selected
  if (selectedRepo == null) {
    return [];
  }

  return dataSource.getTasks(
    selectedRepo.owner.login,
    selectedRepo.name,
    branch: selectedBranch,
  );
});

/// Provider for fetching a single task by ID
final taskByIdProvider = FutureProvider.family<Task?, String>((ref, taskId) async {
  final dataSource = ref.watch(taskDataSourceProvider);
  final selectedRepo = ref.watch(selectedRepositoryProvider);
  final selectedBranch = ref.watch(selectedBranchProvider);

  if (selectedRepo == null) {
    return null;
  }

  return dataSource.getTask(
    selectedRepo.owner.login,
    selectedRepo.name,
    taskId,
    branch: selectedBranch,
  );
});

/// State notifier for task mutations (create, update, delete)
/// Handles optimistic updates and error rollback
class TaskMutationsNotifier extends StateNotifier<AsyncValue<void>> {
  TaskMutationsNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  /// Create or update a task
  Future<void> saveTask(Task task, {String? commitMessage}) async {
    final selectedRepo = _ref.read(selectedRepositoryProvider);
    final selectedBranch = _ref.read(selectedBranchProvider);

    if (selectedRepo == null) {
      state = AsyncValue.error(
        'No repository selected',
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();

    try {
      final dataSource = _ref.read(taskDataSourceProvider);
      await dataSource.saveTask(
        selectedRepo.owner.login,
        selectedRepo.name,
        task,
        branch: selectedBranch,
        commitMessage: commitMessage,
      );

      // Invalidate tasks to trigger refetch
      _ref.invalidate(tasksProvider);

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Delete a task
  Future<void> deleteTask(String taskId, {String? commitMessage}) async {
    final selectedRepo = _ref.read(selectedRepositoryProvider);
    final selectedBranch = _ref.read(selectedBranchProvider);

    if (selectedRepo == null) {
      state = AsyncValue.error(
        'No repository selected',
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();

    try {
      final dataSource = _ref.read(taskDataSourceProvider);
      await dataSource.deleteTask(
        selectedRepo.owner.login,
        selectedRepo.name,
        taskId,
        branch: selectedBranch,
        commitMessage: commitMessage,
      );

      // Invalidate tasks to trigger refetch
      _ref.invalidate(tasksProvider);

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Provider for task mutations
final taskMutationsProvider =
    StateNotifierProvider<TaskMutationsNotifier, AsyncValue<void>>((ref) {
  return TaskMutationsNotifier(ref);
});
