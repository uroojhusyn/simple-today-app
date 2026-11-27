// lib/main.dart
//
// Beginner‑friendly Flutter To‑Do / Task Manager app.
// Uses Material 3 with a teal colour scheme and persists tasks
// using the shared_preferences package.
// ---------------------------------------------------------

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const TodoApp());
}

/// Root widget of the app.
class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple To‑Do',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const TodoHomePage(),
    );
  }
}

/// Home page containing the UI for adding tasks and the task list.
class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  // In‑memory list of tasks.
  final List<_TaskItem> _tasks = [];

  // Controller for the input field.
  final TextEditingController _controller = TextEditingController();

  // Key used in SharedPreferences.
  static const _kTasksKey = 'tasks';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Load tasks from SharedPreferences.
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_kTasksKey);
    if (jsonString == null) return;
    try {
      final List<dynamic> decoded = json.decode(jsonString);
      setState(() {
        _tasks.clear();
        for (final item in decoded) {
          _tasks.add(_TaskItem(
            title: item['title'] as String,
            completed: item['completed'] as bool? ?? false,
          ));
        }
      });
    } catch (e) {
      // If decoding fails, start with an empty list.
    }
  }

  /// Save the current task list to SharedPreferences.
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> encoded = _tasks
        .map((t) => {'title': t.title, 'completed': t.completed})
        .toList();
    await prefs.setString(_kTasksKey, json.encode(encoded));
  }

  /// Add a new task from the text field.
  void _addTask() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _tasks.add(_TaskItem(title: text));
    });
    _controller.clear();
    _saveTasks();
  }

  /// Remove a task at the given index.
  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks();
  }

  /// Toggle the completed state of a task.
  void _toggleTask(int index) {
    setState(() {
      _tasks[index].completed = !_tasks[index].completed;
    });
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple To‑Do')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter a new task',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTask,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Task list
            Expanded(
              child: _tasks.isEmpty
                  ? const Center(
                      child: Text(
                        'No tasks yet. Add one above!',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        return ListTile(
                          leading: Checkbox(
                            value: task.completed,
                            onChanged: (_) => _toggleTask(index),
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              decoration: task.completed
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            tooltip: 'Delete task',
                            onPressed: () => _removeTask(index),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple data class representing a task.
class _TaskItem {
  _TaskItem({required this.title, this.completed = false});

  final String title;
  bool completed;
}
