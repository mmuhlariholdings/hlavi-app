import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/branch_selector.dart';
import '../../../../shared/widgets/repository_selector.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../../../../shared/widgets/stat_card_shimmer.dart';
import '../../../repository/presentation/providers/repository_providers.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/domain/entities/task_status.dart';
import '../../../tasks/presentation/providers/task_providers.dart';

/// Main dashboard screen showing task statistics and repository management
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRepo = ref.watch(selectedRepositoryProvider);
    final selectedBranch = ref.watch(selectedBranchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // TODO: Implement sign out
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Invalidate providers to trigger refresh
          ref.invalidate(repositoriesProvider);
          if (selectedRepo != null) {
            ref.invalidate(tasksProvider);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Repository selection section
              const Text(
                'Repository',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const RepositorySelector(),
              const SizedBox(height: 16),

              // Branch selection section (only shown if repo is selected)
              if (selectedRepo != null) ...[
                const Text(
                  'Branch',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const BranchSelector(),
                const SizedBox(height: 24),
              ],

              // .hlavi validation and statistics
              if (selectedRepo != null && selectedBranch != null)
                _HlaviValidationSection(),

              // Instructions when no repo is selected
              if (selectedRepo == null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Select a repository to get started',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget that handles .hlavi directory validation and displays statistics
class _HlaviValidationSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRepo = ref.watch(selectedRepositoryProvider)!;
    final selectedBranch = ref.watch(selectedBranchProvider);

    final hasHlaviAsync = ref.watch(
      hasHlaviDirectoryProvider((
        owner: selectedRepo.owner.login,
        repo: selectedRepo.name,
        branch: selectedBranch,
      )),
    );

    return hasHlaviAsync.when(
      data: (hasHlavi) {
        if (!hasHlavi) {
          return _InitializeHlaviCard();
        }

        // Show statistics if .hlavi exists
        return _StatisticsSection();
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, stack) => Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Error checking .hlavi directory',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card shown when .hlavi directory doesn't exist
class _InitializeHlaviCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.folder_outlined,
              size: 64,
              color: Colors.orange[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Hlavi Not Initialized',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This repository doesn\'t have a .hlavi directory yet. Initialize it to start managing tasks.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Show initialize dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Initialize .hlavi coming soon!'),
                  ),
                );
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Initialize Hlavi'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Statistics section showing task counts
class _StatisticsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);

    return tasksAsync.when(
      data: (tasks) {
        final stats = _calculateStatistics(tasks);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                StatCard(
                  title: 'Total Tasks',
                  value: stats.total,
                  icon: Icons.task_alt,
                  color: Colors.blue,
                ),
                StatCard(
                  title: 'Completed',
                  value: stats.completed,
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                StatCard(
                  title: 'In Progress',
                  value: stats.inProgress,
                  icon: Icons.pending,
                  color: Colors.orange,
                ),
                StatCard(
                  title: 'Blocked',
                  value: stats.blocked,
                  icon: Icons.block,
                  color: Colors.red,
                ),
              ],
            ),
          ],
        );
      },
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: const [
              StatCardShimmer(),
              StatCardShimmer(),
              StatCardShimmer(),
              StatCardShimmer(),
            ],
          ),
        ],
      ),
      error: (error, stack) => Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Error loading tasks',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _TaskStatistics _calculateStatistics(List<Task> tasks) {
    return _TaskStatistics(
      total: tasks.length,
      completed: tasks.where((t) => t.status == TaskStatus.done || t.status == TaskStatus.closed).length,
      inProgress: tasks.where((t) => t.status == TaskStatus.inProgress).length,
      blocked: tasks.where((t) => t.status == TaskStatus.pending).length,
    );
  }
}

class _TaskStatistics {
  const _TaskStatistics({
    required this.total,
    required this.completed,
    required this.inProgress,
    required this.blocked,
  });

  final int total;
  final int completed;
  final int inProgress;
  final int blocked;
}
