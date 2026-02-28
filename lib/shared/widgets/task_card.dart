import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../features/tasks/domain/entities/task.dart';
import '../../features/tasks/domain/entities/task_status.dart';
import 'task_status_badge.dart';

/// Reusable task card widget matching the web app's TaskCard.tsx
/// Displays task information in a compact, consistent format
class TaskCard extends StatelessWidget {
  const TaskCard({
    required this.task,
    this.onTap,
    super.key,
  });

  final Task task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final completedAC = task.acceptanceCriteria.where((ac) => ac.completed).length;
    final totalAC = task.acceptanceCriteria.length;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: ID + Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Task ID
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      task.id,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                        fontFamily: 'SpaceGrotesk',
                      ),
                    ),
                  ),
                  // Status Badge
                  TaskStatusBadge(status: task.status),
                ],
              ),
              const SizedBox(height: 12),

              // Title (max 2 lines)
              Text(
                task.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'SpaceGrotesk',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // Description (max 2 lines, if exists)
              if (task.description != null && task.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  task.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Footer: AC Progress + Due Date
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Acceptance Criteria Progress
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$completedAC/$totalAC',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  // Due Date (if exists)
                  if (task.endDate != null)
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: _getDueDateColor(task.endDate!),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Due: ${DateFormat('MMM d').format(task.endDate!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: _getDueDateColor(task.endDate!),
                            fontWeight: _isOverdue(task.endDate!)
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Check if task is overdue
  bool _isOverdue(DateTime endDate) {
    return endDate.isBefore(DateTime.now()) && task.status != TaskStatus.done && task.status != TaskStatus.closed;
  }

  /// Get color for due date based on proximity and status
  Color _getDueDateColor(DateTime endDate) {
    if (_isOverdue(endDate)) {
      return Colors.red.shade700; // Overdue - red
    }

    final daysUntilDue = endDate.difference(DateTime.now()).inDays;
    if (daysUntilDue <= 3) {
      return Colors.orange.shade700; // Due soon - orange
    }

    return Colors.grey.shade600; // Normal - gray
  }
}
