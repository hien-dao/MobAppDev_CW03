import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/task_service.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _taskController = TextEditingController();
  List<Task> _tasks = [];

  TaskService? _taskService;
  late Stream<List<Task>> _taskStream;

  @override
  void initState() {
    super.initState();
    _taskService = TaskService();
    _taskStream = _taskService!.getTasks();
  }

  @override
  void dispose() {
    _taskController.dispose(); // IMPORTANT: always dispose controllers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Manager')),
      body: Column(
        children: [
          // ── Input row ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(child: TextField(controller: _taskController,
                decoration: const InputDecoration(hintText: 'New task name...'),
              )),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: () => _taskService.addTask(Task(
                id: DateTime.now().toIso8601String(),
                title: _taskController.text.trim(),
                createdAt: DateTime.now(),
              )), child: const Text('Add')),
            ]),
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
                final tasks = snapshot.data!;
                if (tasks.isEmpty) {
                  return const Center(child: Text('No tasks yet!'));
                }
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      title: Text(task.title),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _taskService.deleteTask(task.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}