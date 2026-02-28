import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/repository_selector.dart';
import '../../../../shared/widgets/branch_selector.dart';
import '../../../repository/presentation/providers/repository_providers.dart';
import '../../../repository/presentation/providers/board_providers.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../widgets/kanban_column.dart';

/// Kanban board view
/// Displays tasks in columns by status with horizontal scrolling
class BoardScreen extends ConsumerWidget {
  const BoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRepo = ref.watch(selectedRepositoryProvider);
    final selectedBranch = ref.watch(selectedBranchProvider);
    final hasHlaviAsync = selectedRepo != null
        ? ref.watch(hasHlaviDirectoryProvider((
            owner: selectedRepo.owner.login,
            repo: selectedRepo.name,
            branch: selectedBranch,
          )))
        : const AsyncValue.data(false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Board'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                const RepositorySelector(),
                const SizedBox(height: 8),
                if (selectedRepo != null) const BranchSelector(),
              ],
            ),
          ),
        ),
      ),
      body: hasHlaviAsync.when(
        data: (hasHlavi) {
          if (selectedRepo == null) {
            return _buildEmptyState(
              icon: Icons.folder_outlined,
              title: 'No Repository Selected',
              message: 'Select a repository to view the board',
            );
          }

          if (!hasHlavi) {
            return _buildEmptyState(
              icon: Icons.warning_amber_outlined,
              title: 'No .hlavi Directory',
              message: 'This repository does not have a .hlavi directory.\nInitialize hlavi to use the board view.',
            );
          }

          return const _BoardContent();
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildEmptyState(
          icon: Icons.error_outline,
          title: 'Error',
          message: error.toString(),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Board content widget showing columns and tasks
class _BoardContent extends ConsumerWidget {
  const _BoardContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);
    final boardConfigAsync = ref.watch(currentBoardConfigProvider);

    // Calculate column width: 85% of screen width to show hint of next column
    final screenWidth = MediaQuery.of(context).size.width;
    final columnWidth = screenWidth * 0.85;

    return tasksAsync.when(
      data: (tasks) {
        return boardConfigAsync.when(
          data: (boardConfig) {
            if (boardConfig == null) {
              return const Center(child: Text('No board configuration'));
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(tasksProvider);
                ref.invalidate(currentBoardConfigProvider);
              },
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(16),
                itemCount: boardConfig.columns.length,
                itemBuilder: (context, index) {
                  final column = boardConfig.columns[index];

                  return KanbanColumn(
                    column: column,
                    tasks: tasks,
                    width: columnWidth,
                    onTaskTap: (task) {
                      context.push('/tasks/${task.id}');
                    },
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error loading board: $error'),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading tasks: $error'),
          ],
        ),
      ),
    );
  }
}
