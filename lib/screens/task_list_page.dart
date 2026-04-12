import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/task_service.dart';

class TaskListScreen extends StatefulWidget {
  final Function(bool) onToggleTheme;
  final bool isDarkMode;

  const TaskListScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  late TaskService _taskService;
  late Stream<List<Task>> _taskStream;

  @override
  void initState() {
    super.initState();
    _taskService = TaskService();
    _taskStream = _taskService.getTasks();
  }

  @override
  void dispose() {
    _taskController.dispose(); // IMPORTANT: always dispose controllers
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _createOrUpdateTask({Task? task}) async {
    final isEdit = task != null;

    // Pre-fill when editing
    _taskController.text = task?.title ?? '';

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(isEdit ? 'Update Task' : 'Create Task'),
          content: TextField(
            controller: _taskController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _taskController.clear();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              child: Text(isEdit ? 'Update' : 'Create'),
              onPressed: () async {
                final text = _taskController.text.trim();
                if (text.isEmpty) return;

                if (isEdit) {
                  await _taskService.updateTask(
                    Task(
                      id: task.id,
                      title: text,
                      createdAt: task.createdAt, // keep original
                      isCompleted: task.isCompleted,
                    ),
                  );
                } else {
                  await _taskService.addTask(
                    Task(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: text,
                      createdAt: DateTime.now(),
                    ),
                  );
                }

                Navigator.of(ctx).pop();
                _taskController.clear();
              },
            ),
          ],
        );
      },
    );

    // Safety clear (in case dialog dismissed by tapping outside)
    _taskController.clear();
  }

  Widget _buildSubtasks(Task task) {
    return Column(
      children: [
        ...task.subtasks.asMap().entries.map((entry) {
          final index = entry.key;
          final subtask = entry.value;

          return ListTile(
            title: Text(subtask['title'] ?? ''),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeSubtask(task, index),
            ),
          );
        }),

        TextButton.icon(
          onPressed: () => _addSubtask(task),
          icon: const Icon(Icons.add),
          label: const Text('Add Subtask'),
        ),
      ],
    );
  }

  Future<void> _addSubtask(Task task) async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Subtask'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Subtask name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty) return;

              final updatedSubtasks = List<Map<String, dynamic>>.from(task.subtasks)
                ..add({'title': text});

              await _taskService.updateTask(
                task.copyWith(subtasks: updatedSubtasks),
              );

              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _removeSubtask(Task task, int index) async {
    final updatedSubtasks = List<Map<String, dynamic>>.from(task.subtasks)
      ..removeAt(index);

    await _taskService.updateTask(
      task.copyWith(subtasks: updatedSubtasks),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Task Manager',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        actions: [
          Row(
            children: [
              const Icon(Icons.light_mode),
              Switch(
                value: widget.isDarkMode,
                onChanged: widget.onToggleTheme,
              ),
              const Icon(Icons.dark_mode),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search Bar ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          // ── Task list ──────────────────────────────────────────
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: _taskStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final allTasks = snapshot.data!;

                final tasks = allTasks.where((task) {
                  return task.title.toLowerCase().contains(_searchQuery);
                }).toList();
                if (tasks.isEmpty) {
                  return const Center(child: Text('No tasks yet!'));
                }
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ExpansionTile(
                        title: Text(task.title),
                        subtitle: Text('Created at: ${task.createdAt}'),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                task.isCompleted
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: task.isCompleted ? Colors.green : null,
                              ),
                              onPressed: () => _taskService.toggleTaskCompletion(task),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _createOrUpdateTask(task: task),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _taskService.deleteTask(task.id),
                            ),
                          ],
                        ),

                        children: [
                          _buildSubtasks(task),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // ── Add Task Button ─────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdateTask(),
        child: const Icon(Icons.add),
      ),
    );
  }
}