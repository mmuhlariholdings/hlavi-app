import 'package:flutter/material.dart';

import '../../features/tasks/domain/entities/task_status.dart';

/// Badge widget to display task status with color coding
/// Matches the web app's status badge styling
class TaskStatusBadge extends StatelessWidget {
  const TaskStatusBadge({
    required this.status,
    super.key,
  });

  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: config.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: config.color,
        ),
      ),
    );
  }

  _StatusConfig _getStatusConfig(TaskStatus status) {
    switch (status) {
      case TaskStatus.newStatus:
        return const _StatusConfig(
          label: 'New',
          color: Color(0xFF6B7280), // Gray
        );
      case TaskStatus.open:
        return const _StatusConfig(
          label: 'Open',
          color: Color(0xFF3B82F6), // Blue
        );
      case TaskStatus.inProgress:
        return const _StatusConfig(
          label: 'In Progress',
          color: Color(0xFFF59E0B), // Amber/Orange
        );
      case TaskStatus.pending:
        return const _StatusConfig(
          label: 'Pending',
          color: Color(0xFFEF4444), // Red
        );
      case TaskStatus.review:
        return const _StatusConfig(
          label: 'Review',
          color: Color(0xFF8B5CF6), // Purple
        );
      case TaskStatus.done:
        return const _StatusConfig(
          label: 'Done',
          color: Color(0xFF10B981), // Green
        );
      case TaskStatus.closed:
        return const _StatusConfig(
          label: 'Closed',
          color: Color(0xFF6B7280), // Gray
        );
    }
  }
}

class _StatusConfig {
  const _StatusConfig({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;
}
