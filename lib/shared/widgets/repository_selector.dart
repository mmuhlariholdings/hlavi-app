import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/repository/domain/entities/repository.dart';
import '../../features/repository/presentation/providers/repository_providers.dart';

/// Repository selector dropdown widget
/// Allows users to select a repository from their GitHub repositories
class RepositorySelector extends ConsumerWidget {
  const RepositorySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repositoriesAsync = ref.watch(repositoriesProvider);
    final selectedRepo = ref.watch(selectedRepositoryProvider);

    return repositoriesAsync.when(
      data: (repositories) {
        if (repositories.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No repositories found'),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: DropdownButton<Repository>(
              isExpanded: true,
              value: selectedRepo,
              hint: const Text('Select a repository'),
              underline: const SizedBox.shrink(),
              items: repositories.map((repo) {
                return DropdownMenuItem<Repository>(
                  value: repo,
                  child: Row(
                    children: [
                      Icon(
                        repo.private ? Icons.lock : Icons.public,
                        size: 16,
                        color: repo.private ? Colors.orange : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          repo.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (Repository? repo) {
                if (repo != null) {
                  ref.read(selectedRepositoryProvider.notifier).state = repo;
                  // Reset branch selection when repository changes
                  ref.read(selectedBranchProvider.notifier).state = null;
                }
              },
            ),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, stack) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Error loading repositories: ${error.toString()}',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
