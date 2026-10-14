import 'dart:collection';

import 'package:flutter/material.dart';

enum TodoPriority {
  low('Low'),
  normal('Normal'),
  high('High');

  const TodoPriority(this.label);
  final String label;
}

/// Immutable task data prevents changes outside TodoProvider.
class MyTodo {
  const MyTodo({
    required this.id,
    required this.name,
    required this.priority,
    this.completed = false,
  });

  final int id;
  final String name;
  final TodoPriority priority;
  final bool completed;

  MyTodo withCompleted(bool value) =>
      MyTodo(id: id, name: name, priority: priority, completed: value);
}

/// Owns the tasks, form input, selected priority and all state changes.
class TodoProvider extends ChangeNotifier {
  final List<MyTodo> _todos = [];
  final TextEditingController controller = TextEditingController();
  TodoPriority _priority = TodoPriority.normal;
  int _nextId = 1;

  UnmodifiableListView<MyTodo> get todos => UnmodifiableListView(_todos);
  TodoPriority get priority => _priority;

  void setPriority(TodoPriority value) {
    if (_priority == value) return;
    _priority = value;
    notifyListeners();
  }

  /// Returns false for blank input; the page displays the validation dialog.
  bool addTodo() {
    final name = controller.text.trim();
    if (name.isEmpty) return false;
    _todos.add(MyTodo(id: _nextId++, name: name, priority: _priority));
    controller.clear();
    notifyListeners();
    return true;
  }

  void toggleTodoStatus(int index, bool value) {
    if (_todos[index].completed == value) return;
    _todos[index] = _todos[index].withCompleted(value);
    notifyListeners();
  }

  void removeTodo(int index) {
    _todos.removeAt(index);
    notifyListeners();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
