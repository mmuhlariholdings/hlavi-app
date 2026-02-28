import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/selected_date_provider.dart';

/// Date selector with quick options and custom date picker
class DateSelector extends ConsumerWidget {
  const DateSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final notifier = ref.read(selectedDateProvider.notifier);

    // Determine which period is selected
    var selectedPeriod = 'custom';
    if (_isToday(selectedDate)) {
      selectedPeriod = 'today';
    } else if (_isTomorrow(selectedDate)) {
      selectedPeriod = 'tomorrow';
    } else if (_isThisWeek(selectedDate)) {
      selectedPeriod = 'this_week';
    } else if (_isThisMonth(selectedDate)) {
      selectedPeriod = 'this_month';
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Calendar icon
            Icon(
              Icons.calendar_today,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),

            // Date period dropdown
            Expanded(
              child: DropdownButton<String>(
                value: selectedPeriod,
                isExpanded: true,
                isDense: true,
                underline: const SizedBox.shrink(),
                icon: const Icon(Icons.arrow_drop_down, size: 20),
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontFamily: 'SpaceGrotesk',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'today',
                    child: Text('Today'),
                  ),
                  DropdownMenuItem(
                    value: 'tomorrow',
                    child: Text('Tomorrow'),
                  ),
                  DropdownMenuItem(
                    value: 'this_week',
                    child: Text('This Week'),
                  ),
                  DropdownMenuItem(
                    value: 'this_month',
                    child: Text('This Month'),
                  ),
                  DropdownMenuItem(
                    value: 'custom',
                    child: Text('Custom Date'),
                  ),
                ],
                onChanged: (String? period) {
                  if (period == null) {
                    return;
                  }

                  switch (period) {
                    case 'today':
                      notifier.setToday();
                      break;
                    case 'tomorrow':
                      notifier.setTomorrow();
                      break;
                    case 'this_week':
                      notifier.setThisWeek();
                      break;
                    case 'this_month':
                      notifier.setThisMonth();
                      break;
                    case 'custom':
                      _showCustomDatePicker(context, notifier);
                      break;
                  }
                },
              ),
            ),

            const SizedBox(width: 12),

            // Current date display
            Text(
              DateFormat('MMM d, y').format(selectedDate),
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontFamily: 'SpaceGrotesk',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCustomDatePicker(
    BuildContext context,
    SelectedDateNotifier notifier,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      notifier.setDate(picked);
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  bool _isThisWeek(DateTime date) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return date.year == monday.year &&
        date.month == monday.month &&
        date.day == monday.day;
  }

  bool _isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == 1;
  }
}
