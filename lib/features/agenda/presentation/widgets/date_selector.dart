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

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current selected date display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEEE, MMMM d, y').format(selectedDate),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SpaceGrotesk',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today, size: 20),
                  onPressed: () => _showCustomDatePicker(context, notifier),
                  tooltip: 'Pick custom date',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Quick date selection buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _QuickDateChip(
                  label: 'Today',
                  onPressed: () => notifier.setToday(),
                  isSelected: _isToday(selectedDate),
                ),
                _QuickDateChip(
                  label: 'Tomorrow',
                  onPressed: () => notifier.setTomorrow(),
                  isSelected: _isTomorrow(selectedDate),
                ),
                _QuickDateChip(
                  label: 'This Week',
                  onPressed: () => notifier.setThisWeek(),
                  isSelected: _isThisWeek(selectedDate),
                ),
                _QuickDateChip(
                  label: 'This Month',
                  onPressed: () => notifier.setThisMonth(),
                  isSelected: _isThisMonth(selectedDate),
                ),
              ],
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

/// Quick date selection chip
class _QuickDateChip extends StatelessWidget {
  const _QuickDateChip({
    required this.label,
    required this.onPressed,
    required this.isSelected,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onPressed(),
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
    );
  }
}
