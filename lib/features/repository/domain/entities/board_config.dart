import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../tasks/domain/entities/task_status.dart';

part 'board_config.freezed.dart';
part 'board_config.g.dart';

/// Board configuration matching the web app's BoardConfig interface
@freezed
class BoardConfig with _$BoardConfig {
  const factory BoardConfig({
    /// Board name
    required String name,

    /// Column configuration for the Kanban board
    required List<BoardColumn> columns,
  }) = _BoardConfig;

  factory BoardConfig.fromJson(Map<String, dynamic> json) =>
      _$BoardConfigFromJson(json);
}

/// Board column configuration
@freezed
class BoardColumn with _$BoardColumn {
  const factory BoardColumn({
    /// Column display name (e.g., "In Progress", "Review")
    required String name,

    /// Associated task status
    required TaskStatus status,

    /// Whether agent automation is enabled for this column
    @JsonKey(name: 'agent_enabled') required bool agentEnabled,

    /// Agent automation mode
    @JsonKey(name: 'agent_mode') AgentMode? agentMode,
  }) = _BoardColumn;

  factory BoardColumn.fromJson(Map<String, dynamic> json) =>
      _$BoardColumnFromJson(json);
}

/// Agent automation mode
enum AgentMode {
  /// Agent requires user approval before taking actions
  @JsonValue('attended')
  attended,

  /// Agent can take actions automatically without user approval
  @JsonValue('unattended')
  unattended,
}

/// Full board state including configuration and task mappings
@freezed
class Board with _$Board {
  const factory Board({
    /// Board configuration
    required BoardConfig config,

    /// Mapping of task IDs to their current status
    required Map<String, String> tasks,

    /// Counter for auto-incrementing task IDs
    @JsonKey(name: 'next_task_number') required int nextTaskNumber,
  }) = _Board;

  factory Board.fromJson(Map<String, dynamic> json) => _$BoardFromJson(json);
}
