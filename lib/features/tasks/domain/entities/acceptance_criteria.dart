import 'package:freezed_annotation/freezed_annotation.dart';

part 'acceptance_criteria.freezed.dart';
part 'acceptance_criteria.g.dart';

/// Acceptance criteria for a task
/// Represents a specific requirement that must be met for the task to be considered complete
@freezed
class AcceptanceCriteria with _$AcceptanceCriteria {
  const factory AcceptanceCriteria({
    /// Unique identifier for this criterion
    required int id,

    /// Description of what needs to be accomplished
    required String description,

    /// Whether this criterion has been met
    required bool completed,

    /// When this criterion was created
    @JsonKey(name: 'created_at') required DateTime createdAt,

    /// When this criterion was completed (null if not completed)
    @JsonKey(name: 'completed_at') DateTime? completedAt,
  }) = _AcceptanceCriteria;

  factory AcceptanceCriteria.fromJson(Map<String, dynamic> json) =>
      _$AcceptanceCriteriaFromJson(json);
}
