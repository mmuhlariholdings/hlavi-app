import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/repository_breadcrumb.dart';
import '../../../../shared/widgets/task_card.dart';
import '../../../repository/presentation/providers/repository_providers.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/domain/entities/task_status.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../providers/selected_date_provider.dart';
import '../widgets/date_selector.dart';

/// Agenda view - displays tasks filtered and grouped by date
class AgendaScreen extends ConsumerWidget {
  const AgendaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRepo = ref.watch(selectedRepositoryProvider);
    final mutationState = ref.watch(taskMutationsProvider);
    final tasksAsync = selectedRepo != null ? ref.watch(tasksProvider) : null;

    // Show progress indicator when loading or mutating
    final isUpdating =
        mutationState.isLoading || (tasksAsync?.isLoading ?? false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        // Repository breadcrumb and progress indicator
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(isUpdating ? 62 : 60),
          child: Column(
            children: [
              const RepositoryBreadcrumb(),
              if (isUpdating)
                const SizedBox(
                  height: 2,
                  child: LinearProgressIndicator(minHeight: 2),
                ),
            ],
          ),
        ),
      ),
      body: selectedRepo == null
          ? _buildEmptyState(
              icon: Icons.folder_outlined,
              title: 'No Repository Selected',
              message: 'Select a repository to view the agenda',
            )
          : const _AgendaContent(),
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

/// Agenda content widget showing grouped tasks
class _AgendaContent extends ConsumerWidget {
  const _AgendaContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    return tasksAsync.when(
      data: (tasks) {
        final groupedTasks = _groupTasks(tasks, selectedDate);

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(tasksProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Date selector
                const DateSelector(),

                // Task groups
                _AgendaSection(
                  title: 'Overdue',
                  tasks: groupedTasks.overdue,
                  color: Colors.red,
                  icon: Icons.error_outline,
                ),
                _AgendaSection(
                  title: 'Due Today',
                  tasks: groupedTasks.dueToday,
                  color: Colors.green,
                  icon: Icons.today,
                ),
                _AgendaSection(
                  title: 'Starting Today',
                  tasks: groupedTasks.startingToday,
                  color: Colors.blue,
                  icon: Icons.play_arrow,
                ),
                _AgendaSection(
                  title: 'In Progress',
                  tasks: groupedTasks.inProgress,
                  color: Colors.orange,
                  icon: Icons.pending,
                ),
                _AgendaSection(
                  title: 'No Dates',
                  tasks: groupedTasks.noDates,
                  color: Colors.grey,
                  icon: Icons.calendar_today_outlined,
                ),
              ],
            ),
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

  _GroupedTasks _groupTasks(List<Task> tasks, DateTime selectedDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    final overdue = <Task>[];
    final dueToday = <Task>[];
    final startingToday = <Task>[];
    final inProgress = <Task>[];
    final noDates = <Task>[];

    for (final task in tasks) {
      // Check if task is in progress
      if (task.status == TaskStatus.inProgress) {
        inProgress.add(task);
        continue;
      }

      // Check if task has no dates
      if (task.startDate == null && task.endDate == null) {
        noDates.add(task);
        continue;
      }

      // Check end date (due date)
      if (task.endDate != null) {
        final endDate = DateTime(
          task.endDate!.year,
          task.endDate!.month,
          task.endDate!.day,
        );

        // Overdue check
        if (endDate.isBefore(today) &&
            task.status != TaskStatus.done &&
            task.status != TaskStatus.closed) {
          overdue.add(task);
          continue;
        }

        // Due today check
        if (endDate.isAtSameMomentAs(selected)) {
          dueToday.add(task);
          continue;
        }
      }

      // Check start date
      if (task.startDate != null) {
        final startDate = DateTime(
          task.startDate!.year,
          task.startDate!.month,
          task.startDate!.day,
        );

        // Starting today check
        if (startDate.isAtSameMomentAs(selected)) {
          startingToday.add(task);
          continue;
        }
      }
    }

    return _GroupedTasks(
      overdue: overdue,
      dueToday: dueToday,
      startingToday: startingToday,
      inProgress: inProgress,
      noDates: noDates,
    );
  }
}

/// Expandable section for a group of tasks
class _AgendaSection extends StatefulWidget {
  const _AgendaSection({
    required this.title,
    required this.tasks,
    required this.color,
    required this.icon,
  });

  final String title;
  final List<Task> tasks;
  final Color color;
  final IconData icon;

  @override
  State<_AgendaSection> createState() => _AgendaSectionState();
}

class _AgendaSectionState extends State<_AgendaSection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    if (widget.tasks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          // Section header
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.1),
                borderRadius: _isExpanded
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      )
                    : BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.icon,
                    color: widget.color,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: widget.color,
                      fontFamily: 'SpaceGrotesk',
                    ),
                  ),
                  const Spacer(),
                  // Count badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${widget.tasks.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: widget.color,
                  ),
                ],
              ),
            ),
          ),

          // Task list
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: widget.tasks
                    .map((task) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TaskCard(
                            task: task,
                            onTap: () {
                              context.push('/tasks/${task.id}');
                            },
                          ),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

/// Container for grouped tasks
class _GroupedTasks {
  const _GroupedTasks({
    required this.overdue,
    required this.dueToday,
    required this.startingToday,
    required this.inProgress,
    required this.noDates,
  });

  final List<Task> overdue;
  final List<Task> dueToday;
  final List<Task> startingToday;
  final List<Task> inProgress;
  final List<Task> noDates;
}
