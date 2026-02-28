import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/routes.dart';
import '../../features/repository/presentation/providers/repository_providers.dart';

/// Repository and branch breadcrumb navigation
/// Shows repository (clickable to dashboard) and branch selector
/// Matches web app's breadcrumb pattern
class RepositoryBreadcrumb extends ConsumerWidget {
  const RepositoryBreadcrumb({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRepo = ref.watch(selectedRepositoryProvider);
    final selectedBranch = ref.watch(selectedBranchProvider);

    if (selectedRepo == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.warning_amber, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              'No repository selected',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.go(Routes.dashboard),
              child: const Text('Select Repository'),
            ),
          ],
        ),
      );
    }

    final branchesAsync = ref.watch(branchesProvider((
      owner: selectedRepo.owner.login,
      repo: selectedRepo.name,
    )));

    // Auto-select first branch if none selected
    branchesAsync.whenData((branches) {
      if (selectedBranch == null && branches.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(selectedBranchProvider.notifier).state = branches.first;
        });
      }
    });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Repository (clickable to dashboard)
          InkWell(
            onTap: () => context.go(Routes.dashboard),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.folder_outlined,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  selectedRepo.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                    fontFamily: 'SpaceGrotesk',
                  ),
                ),
              ],
            ),
          ),

          // Separator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.chevron_right,
              size: 16,
              color: Colors.grey[400],
            ),
          ),

          // Branch selector
          Expanded(
            child: branchesAsync.when(
              data: (branches) {
                return DropdownButton<String>(
                  value: selectedBranch,
                  isExpanded: true,
                  isDense: true,
                  underline: const SizedBox.shrink(),
                  icon: const Icon(Icons.arrow_drop_down, size: 20),
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontFamily: 'SpaceGrotesk',
                  ),
                  items: branches.map((branch) {
                    return DropdownMenuItem(
                      value: branch,
                      child: Row(
                        children: [
                          const Icon(Icons.code_outlined, size: 14),
                          const SizedBox(width: 6),
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
                  onChanged: (newBranch) {
                    if (newBranch != null) {
                      ref.read(selectedBranchProvider.notifier).state = newBranch;
                    }
                  },
                );
              },
              loading: () => Row(
                children: [
                  const Icon(Icons.code_outlined, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    selectedBranch ?? 'Loading...',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ),
              error: (error, stack) => Row(
                children: [
                  const Icon(Icons.code_outlined, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    selectedBranch ?? 'Error loading branches',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
