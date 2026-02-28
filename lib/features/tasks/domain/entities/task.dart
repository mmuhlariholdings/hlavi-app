import 'package:freezed_annotation/freezed_annotation.dart';

import 'acceptance_criteria.dart';
import 'task_status.dart';

part 'task.freezed.dart';
part 'task.g.dart';

/// Task entity matching the web app's TypeScript Task interface
/// Represents a single task with all its metadata and acceptance criteria
@freezed
class Task with _$Task {
  const factory Task({
    /// Unique task identifier (e.g., "HLA1", "HLA2")
    required String id,

    /// Task title/name
    required String title,

    /// Current status of the task
    required TaskStatus status, /// List of acceptance criteria that must be met
    @JsonKey(name: 'acceptance_criteria')
    required List<AcceptanceCriteria> acceptanceCriteria, /// When the task was created
    @JsonKey(name: 'created_at') required DateTime createdAt, /// When the task was last updated
    @JsonKey(name: 'updated_at') required DateTime updatedAt, /// Whether an AI agent is assigned to this task
    @JsonKey(name: 'agent_assigned') required bool agentAssigned, /// Detailed description of the task (optional)
    String? description,

    /// Reason for rejection if task was rejected
    @JsonKey(name: 'rejection_reason') String? rejectionReason,

    /// When the task should start (optional)
    @JsonKey(name: 'start_date') DateTime? startDate,

    /// When the task should end/be completed (optional)
    @JsonKey(name: 'end_date') DateTime? endDate,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}

/// Extension methods for Task
extension TaskExtension on Task {
  /// Calculate the completion percentage based on acceptance criteria
  double get completionPercentage {
    if (acceptanceCriteria.isEmpty) return 0;
    final completed =
        acceptanceCriteria.where((ac) => ac.completed).length;
    return completed / acceptanceCriteria.length;
  }

  /// Get the number of completed acceptance criteria
  int get completedCriteriaCount =>
      acceptanceCriteria.where((ac) => ac.completed).length;

  /// Get the total number of acceptance criteria
  int get totalCriteriaCount => acceptanceCriteria.length;

  /// Check if all acceptance criteria are completed
  bool get allCriteriaCompleted =>
      acceptanceCriteria.isNotEmpty &&
      acceptanceCriteria.every((ac) => ac.completed);

  /// Check if task has date range (for timeline view)
  bool get hasDateRange => startDate != null || endDate != null;

  /// Check if task is overdue
  bool get isOverdue {
    if (endDate == null) return false;
    if (status.isComplete) return false;
    return DateTime.now().isAfter(endDate!);
  }

  /// Check if task starts today
  bool get startsToday {
    if (startDate == null) return false;
    final now = DateTime.now();
    return startDate!.year == now.year &&
        startDate!.month == now.month &&
        startDate!.day == now.day;
  }

  /// Check if task is due today
  bool get isDueToday {
    if (endDate == null) return false;
    final now = DateTime.now();
    return endDate!.year == now.year &&
        endDate!.month == now.month &&
        endDate!.day == now.day;
  }

  /// Check if task is in progress (based on status)
  bool get isInProgress => status == TaskStatus.inProgress;
}
