import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../repository/presentation/providers/repository_providers.dart';

/// Test screen to verify API layer is working
/// Displays user's repositories fetched from GitHub API
class DashboardTestScreen extends ConsumerWidget {
  const DashboardTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repositoriesAsync = ref.watch(repositoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('API Test - My Repositories'),
      ),
      body: repositoriesAsync.when(
        data: (repositories) {
          if (repositories.isEmpty) {
            return const Center(
              child: Text('No repositories found'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: repositories.length,
            itemBuilder: (context, index) {
              final repo = repositories[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.folder),
                  title: Text(repo.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (repo.description != null)
                        Text(
                          repo.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 4),
                      Text(
                        'Owner: ${repo.owner.login}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  trailing: Icon(
                    repo.private ? Icons.lock : Icons.public,
                    color: repo.private ? Colors.orange : Colors.green,
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading repositories',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(repositoriesProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
