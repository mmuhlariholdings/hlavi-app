import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/widgets/task_status_badge.dart';
import '../../domain/entities/acceptance_criteria.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_status.dart';
import '../providers/task_providers.dart';

/// Task detail screen showing full task information
/// Supports viewing and editing task details
class TaskDetailScreen extends ConsumerStatefulWidget {
  const TaskDetailScreen({
    required this.taskId,
    super.key,
  });

  final String taskId;

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Task ${widget.taskId}'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            )
          else
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                });
              },
              child: const Text('Cancel'),
            ),
        ],
      ),
      body: tasksAsync.when(
        data: (tasks) {
          final task = tasks.firstWhere(
            (t) => t.id == widget.taskId,
            orElse: () => throw Exception('Task not found'),
          );

          return _isEditing
              ? _EditTaskView(task: task, onSave: _handleSave)
              : _ReadOnlyTaskView(task: task);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading task: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave(Task updatedTask) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saving task...')),
      );

      // Update task
      await ref.read(taskMutationsProvider.notifier).saveTask(
        updatedTask,
        commitMessage: 'Update task ${updatedTask.id}',
      );

      if (mounted) {
        setState(() {
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Read-only view of task details
class _ReadOnlyTaskView extends StatelessWidget {
  const _ReadOnlyTaskView({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final completedAC = task.acceptanceCriteria.where((ac) => ac.completed).length;
    final totalAC = task.acceptanceCriteria.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task ID and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                task.id,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[600],
                  fontFamily: 'SpaceGrotesk',
                ),
              ),
              TaskStatusBadge(status: task.status),
            ],
          ),
          const SizedBox(height: 16),

          // Title
          const Text(
            'Title',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            task.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: 'SpaceGrotesk',
            ),
          ),
          const SizedBox(height: 24),

          // Description
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            task.description ?? 'No description',
            style: TextStyle(
              fontSize: 16,
              color: task.description != null ? Colors.black : Colors.grey,
            ),
          ),
          const SizedBox(height: 24),

          // Dates
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  'Start Date',
                  task.startDate,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateField(
                  'End Date',
                  task.endDate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Acceptance Criteria
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Acceptance Criteria',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'SpaceGrotesk',
                ),
              ),
              Text(
                '$completedAC/$totalAC',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (task.acceptanceCriteria.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No acceptance criteria',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            )
          else
            ...task.acceptanceCriteria.map((ac) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      ac.completed
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 20,
                      color: ac.completed ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        ac.description,
                        style: TextStyle(
                          fontSize: 14,
                          decoration: ac.completed
                              ? TextDecoration.lineThrough
                              : null,
                          color: ac.completed ? Colors.grey : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 24),

          // Metadata
          const Text(
            'Metadata',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'SpaceGrotesk',
            ),
          ),
          const SizedBox(height: 12),
          _buildMetadataRow('Created', _formatDate(task.createdAt)),
          _buildMetadataRow('Updated', _formatDate(task.updatedAt)),
          _buildMetadataRow(
            'Agent Assigned',
            task.agentAssigned ? 'Yes' : 'No',
          ),
          if (task.rejectionReason != null)
            _buildMetadataRow('Rejection Reason', task.rejectionReason!),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          date != null ? _formatDate(date) : 'Not set',
          style: TextStyle(
            fontSize: 16,
            color: date != null ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }
}

/// Edit view for task details
class _EditTaskView extends StatefulWidget {
  const _EditTaskView({
    required this.task,
    required this.onSave,
  });

  final Task task;
  final Future<void> Function(Task) onSave;

  @override
  State<_EditTaskView> createState() => _EditTaskViewState();
}

class _EditTaskViewState extends State<_EditTaskView> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late TaskStatus _selectedStatus;
  late DateTime? _startDate;
  late DateTime? _endDate;
  late List<AcceptanceCriteria> _acceptanceCriteria;
  final TextEditingController _newCriteriaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(
      text: widget.task.description ?? '',
    );
    _selectedStatus = widget.task.status;
    _startDate = widget.task.startDate;
    _endDate = widget.task.endDate;
    _acceptanceCriteria = List.from(widget.task.acceptanceCriteria);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _newCriteriaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'SpaceGrotesk',
            ),
          ),
          const SizedBox(height: 16),

          // Description
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),

          // Status Dropdown
          DropdownButtonFormField<TaskStatus>(
            value: _selectedStatus,
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
            ),
            items: TaskStatus.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Row(
                  children: [
                    TaskStatusBadge(status: status),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedStatus = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),

          // Dates
          Row(
            children: [
              Expanded(
                child: _buildDatePicker(
                  'Start Date',
                  _startDate,
                  (date) => setState(() => _startDate = date),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDatePicker(
                  'End Date',
                  _endDate,
                  (date) => setState(() => _endDate = date),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Acceptance Criteria
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Acceptance Criteria',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'SpaceGrotesk',
                ),
              ),
              Text(
                '${_acceptanceCriteria.where((ac) => ac.completed).length}/${_acceptanceCriteria.length}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Acceptance Criteria List
          ..._acceptanceCriteria.asMap().entries.map((entry) {
            final index = entry.key;
            final ac = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: ac.completed,
                    onChanged: (value) {
                      setState(() {
                        _acceptanceCriteria[index] = ac.copyWith(
                          completed: value ?? false,
                          completedAt: (value ?? false) ? DateTime.now() : null,
                        );
                      });
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        ac.description,
                        style: TextStyle(
                          fontSize: 14,
                          decoration: ac.completed
                              ? TextDecoration.lineThrough
                              : null,
                          color: ac.completed ? Colors.grey : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () {
                      setState(() {
                        _acceptanceCriteria.removeAt(index);
                      });
                    },
                    color: Colors.red,
                  ),
                ],
              ),
            );
          }),

          // Add new criteria
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newCriteriaController,
                  decoration: const InputDecoration(
                    hintText: 'Add new acceptance criteria',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _addCriteria(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: _addCriteria,
                color: Theme.of(context).primaryColor,
                iconSize: 32,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Save Button
          ElevatedButton(
            onPressed: _handleSave,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime? date,
    void Function(DateTime?) onChanged,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: date != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () => onChanged(null),
                )
              : const Icon(Icons.calendar_today, size: 20),
        ),
        child: Text(
          date != null ? DateFormat('MMM d, y').format(date) : 'Not set',
          style: TextStyle(
            fontSize: 16,
            color: date != null ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  void _addCriteria() {
    final text = _newCriteriaController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      final newId = _acceptanceCriteria.isEmpty
          ? 1
          : _acceptanceCriteria.map((ac) => ac.id).reduce((a, b) => a > b ? a : b) + 1;

      _acceptanceCriteria.add(
        AcceptanceCriteria(
          id: newId,
          description: text,
          completed: false,
          createdAt: DateTime.now(),
        ),
      );
      _newCriteriaController.clear();
    });
  }

  Future<void> _handleSave() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title cannot be empty')),
      );
      return;
    }

    final updatedTask = widget.task.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      status: _selectedStatus,
      startDate: _startDate,
      endDate: _endDate,
      acceptanceCriteria: _acceptanceCriteria,
      updatedAt: DateTime.now(),
    );

    await widget.onSave(updatedTask);
  }
}
