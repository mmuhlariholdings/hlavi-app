import 'package:freezed_annotation/freezed_annotation.dart';

/// Task status enum matching the web app's TypeScript type
/// Represents the current state of a task in the workflow
enum TaskStatus {
  /// Task is newly created
  @JsonValue('new')
  newStatus,

  /// Task is open and ready to be worked on
  @JsonValue('open')
  open,

  /// Task is currently being worked on
  @JsonValue('inprogress')
  inProgress,

  /// Task is waiting for something (dependency, approval, etc.)
  @JsonValue('pending')
  pending,

  /// Task is under review
  @JsonValue('review')
  review,

  /// Task is completed
  @JsonValue('done')
  done,

  /// Task is closed (may be abandoned or completed)
  @JsonValue('closed')
  closed,
}

/// Extension methods for TaskStatus
extension TaskStatusExtension on TaskStatus {
  /// Get human-readable display name
  String get displayName {
    switch (this) {
      case TaskStatus.newStatus:
        return 'New';
      case TaskStatus.open:
        return 'Open';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.review:
        return 'Review';
      case TaskStatus.done:
        return 'Done';
      case TaskStatus.closed:
        return 'Closed';
    }
  }

  /// Get the JSON value for API serialization
  String get jsonValue {
    switch (this) {
      case TaskStatus.newStatus:
        return 'new';
      case TaskStatus.open:
        return 'open';
      case TaskStatus.inProgress:
        return 'inprogress';
      case TaskStatus.pending:
        return 'pending';
      case TaskStatus.review:
        return 'review';
      case TaskStatus.done:
        return 'done';
      case TaskStatus.closed:
        return 'closed';
    }
  }

  /// Check if task is considered complete
  bool get isComplete => this == TaskStatus.done || this == TaskStatus.closed;

  /// Check if task is in an active state
  bool get isActive =>
      this == TaskStatus.open ||
      this == TaskStatus.inProgress ||
      this == TaskStatus.review;
}
