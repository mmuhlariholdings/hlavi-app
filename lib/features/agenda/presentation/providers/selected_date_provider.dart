import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the selected date in the agenda view
/// Controls which tasks are displayed based on date filtering
class SelectedDateNotifier extends StateNotifier<DateTime> {
  SelectedDateNotifier() : super(DateTime.now());

  /// Set the selected date
  void setDate(DateTime date) {
    state = DateTime(date.year, date.month, date.day);
  }

  /// Set to today
  void setToday() {
    final now = DateTime.now();
    state = DateTime(now.year, now.month, now.day);
  }

  /// Set to tomorrow
  void setTomorrow() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    state = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
  }

  /// Set to start of this week (Monday)
  void setThisWeek() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    state = DateTime(monday.year, monday.month, monday.day);
  }

  /// Set to start of this month
  void setThisMonth() {
    final now = DateTime.now();
    state = DateTime(now.year, now.month, 1);
  }
}

/// Provider for selected date in agenda view
final selectedDateProvider =
    StateNotifierProvider<SelectedDateNotifier, DateTime>((ref) {
  return SelectedDateNotifier();
});
