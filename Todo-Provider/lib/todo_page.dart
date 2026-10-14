import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'todo_provider.dart';

class TodoPage extends StatelessWidget {
  const TodoPage({super.key});

  void _showAddTodoSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => Consumer<TodoProvider>(
        builder: (context, provider, child) => SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.viewInsetsOf(context).bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: provider.controller,
                decoration: const InputDecoration(hintText: 'What to do?'),
                textCapitalization: TextCapitalization.sentences,
              ),
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text('Select Priority', textAlign: TextAlign.center),
              ),
              RadioGroup<TodoPriority>(
                groupValue: provider.priority,
                onChanged: (value) {
                  if (value != null) provider.setPriority(value);
                },
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: TodoPriority.values.map((priority) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<TodoPriority>(value: priority),
                        Text(priority.label),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  if (provider.addTodo()) {
                    Navigator.pop(sheetContext);
                  } else {
                    showMsg(sheetContext, 'Input field must not be empty');
                  }
                },
                child: const Text('SAVE'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Todos')),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoSheet(context),
        tooltip: 'Add todo',
        child: const Icon(Icons.add),
      ),
      body: Consumer<TodoProvider>(
        builder: (context, provider, child) {
          if (provider.todos.isEmpty) {
            return const Center(child: Text('Nothing to do!'));
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: provider.todos.length,
            itemBuilder: (context, index) => TodoItem(
              key: ValueKey(provider.todos[index].id),
              todo: provider.todos[index],
              onChanged: (value) => provider.toggleTodoStatus(index, value),
              onRemove: () => provider.removeTodo(index),
            ),
          );
        },
      ),
    );
  }
}

void showMsg(BuildContext context, String message) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Caution!'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('CLOSE'),
        ),
      ],
    ),
  );
}

class TodoItem extends StatelessWidget {
  const TodoItem({
    super.key,
    required this.todo,
    required this.onChanged,
    required this.onRemove,
  });

  final MyTodo todo;
  final ValueChanged<bool> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final color = switch (todo.priority) {
      TodoPriority.low => Colors.green.shade700,
      TodoPriority.normal => Colors.blue.shade700,
      TodoPriority.high => Colors.red.shade700,
    };
    return CheckboxListTile(
      title: Text(
        todo.name,
        style: TextStyle(
          decoration: todo.completed ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text(
        'Priority: ${todo.priority.label}',
        style: TextStyle(color: color),
      ),
      value: todo.completed,
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      secondary: IconButton(
        tooltip: 'Delete ${todo.name}',
        icon: const Icon(Icons.delete_outline),
        onPressed: onRemove,
      ),
    );
  }
}
