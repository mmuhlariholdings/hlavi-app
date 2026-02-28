import 'package:flutter/material.dart';

import '../../../../shared/widgets/task_card.dart';
import '../../../repository/domain/entities/board_config.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/domain/entities/task_status.dart';

/// Kanban column widget for mobile board view
/// Displays tasks for a specific status in a vertical list
class KanbanColumn extends StatelessWidget {
  const KanbanColumn({
    required this.column,
    required this.tasks,
    required this.width,
    this.onTaskTap,
    super.key,
  });

  final BoardColumn column;
  final List<Task> tasks;
  final double width;
  final void Function(Task)? onTaskTap;

  @override
  Widget build(BuildContext context) {
    // Filter tasks for this column's status
    final columnTasks = tasks.where((task) => task.status == column.status).toList();

    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Column Header
          _buildHeader(context, columnTasks.length),

          // Task List
          Expanded(
            child: columnTasks.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: columnTasks.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final task = columnTasks[index];
                      return TaskCard(
                        task: task,
                        onTap: onTaskTap != null ? () => onTaskTap!(task) : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int taskCount) {
    final statusColor = _getStatusColor(column.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(
          bottom: BorderSide(
            color: statusColor.withValues(alpha: 0.2),
            width: 2,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  column.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                    fontFamily: 'SpaceGrotesk',
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$taskCount',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              'No tasks',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get color for task status (matching TaskStatusBadge colors)
  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.newStatus:
        return const Color(0xFF6B7280); // Gray
      case TaskStatus.open:
        return const Color(0xFF3B82F6); // Blue
      case TaskStatus.inProgress:
        return const Color(0xFFF59E0B); // Amber/Orange
      case TaskStatus.pending:
        return const Color(0xFFEF4444); // Red
      case TaskStatus.review:
        return const Color(0xFF8B5CF6); // Purple
      case TaskStatus.done:
        return const Color(0xFF10B981); // Green
      case TaskStatus.closed:
        return const Color(0xFF6B7280); // Gray
    }
  }
}
