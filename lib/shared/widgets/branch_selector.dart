import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/repository/presentation/providers/repository_providers.dart';

/// Branch selector dropdown widget
/// Allows users to select a branch from the selected repository
class BranchSelector extends ConsumerWidget {
  const BranchSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRepo = ref.watch(selectedRepositoryProvider);
    final selectedBranch = ref.watch(selectedBranchProvider);

    // Don't show branch selector if no repository is selected
    if (selectedRepo == null) {
      return const SizedBox.shrink();
    }

    final branchesAsync = ref.watch(
      branchesProvider((owner: selectedRepo.owner.login, repo: selectedRepo.name)),
    );

    return branchesAsync.when(
      data: (branches) {
        if (branches.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No branches found'),
            ),
          );
        }

        // Auto-select default branch if none selected
        if (selectedBranch == null && branches.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Use default branch if available, otherwise first branch
            final branchToSelect = branches.contains(selectedRepo.defaultBranch)
                ? selectedRepo.defaultBranch
                : branches.first;
            ref.read(selectedBranchProvider.notifier).state = branchToSelect;
          });
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedBranch,
              hint: const Text('Select a branch'),
              underline: const SizedBox.shrink(),
              items: branches.map((branch) {
                return DropdownMenuItem<String>(
                  value: branch,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.account_tree,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          branch,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? branch) {
                if (branch != null) {
                  ref.read(selectedBranchProvider.notifier).state = branch;
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
            'Error loading branches: ${error.toString()}',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
