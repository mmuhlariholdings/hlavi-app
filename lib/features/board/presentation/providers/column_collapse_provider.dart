import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../tasks/domain/entities/task_status.dart';

/// Notifier for managing column collapse state
/// Persists state to SharedPreferences
class ColumnCollapseNotifier extends StateNotifier<Map<TaskStatus, bool>> {
  ColumnCollapseNotifier(this._prefsAsync) : super({}) {
    _init();
  }

  final Future<SharedPreferences> _prefsAsync;
  SharedPreferences? _prefs;
  static const _keyPrefix = 'column_collapsed_';

  /// Initialize and load state from SharedPreferences
  Future<void> _init() async {
    _prefs = await _prefsAsync;
    _loadState();
  }

  /// Load collapse state from SharedPreferences
  void _loadState() {
    if (_prefs == null) return;

    final newState = <TaskStatus, bool>{};
    for (final status in TaskStatus.values) {
      final key = _keyPrefix + status.name;
      newState[status] = _prefs!.getBool(key) ?? false;
    }
    state = newState;
  }

  /// Toggle collapse state for a column
  Future<void> toggle(TaskStatus status) async {
    final isCollapsed = state[status] ?? false;
    final newValue = !isCollapsed;

    // Update state
    state = {...state, status: newValue};

    // Persist to SharedPreferences
    if (_prefs != null) {
      final key = _keyPrefix + status.name;
      await _prefs!.setBool(key, newValue);
    }
  }

  /// Get collapse state for a column
  bool isCollapsed(TaskStatus status) {
    return state[status] ?? false;
  }

  /// Expand all columns
  Future<void> expandAll() async {
    final newState = <TaskStatus, bool>{};
    final futures = <Future<void>>[];

    for (final status in TaskStatus.values) {
      newState[status] = false;
      if (_prefs != null) {
        final key = _keyPrefix + status.name;
        futures.add(_prefs!.setBool(key, false));
      }
    }

    // Write all preferences in parallel for better performance
    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }

    state = newState;
  }

  /// Collapse all columns
  Future<void> collapseAll() async {
    final newState = <TaskStatus, bool>{};
    final futures = <Future<void>>[];

    for (final status in TaskStatus.values) {
      newState[status] = true;
      if (_prefs != null) {
        final key = _keyPrefix + status.name;
        futures.add(_prefs!.setBool(key, true));
      }
    }

    // Write all preferences in parallel for better performance
    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }

    state = newState;
  }
}

/// Provider for column collapse state
/// Uses async initialization for SharedPreferences
final columnCollapseProvider = StateNotifierProvider<ColumnCollapseNotifier, Map<TaskStatus, bool>>((ref) {
  return ColumnCollapseNotifier(SharedPreferences.getInstance());
});
