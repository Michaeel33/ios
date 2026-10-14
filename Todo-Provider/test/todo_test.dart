import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/main.dart';
import 'package:todo_app/todo_provider.dart';

void main() {
  test('Provider validates input, notifies and owns immutable tasks', () {
    final provider = TodoProvider();
    addTearDown(provider.dispose);
    var notifications = 0;
    provider.addListener(() => notifications++);
    provider.controller.text = '   ';
    expect(provider.addTodo(), isFalse);
    expect(notifications, 0);
    provider.setPriority(TodoPriority.high);
    provider.controller.text = '  Learn Provider  ';
    expect(provider.addTodo(), isTrue);
    expect(provider.todos.single.name, 'Learn Provider');
    expect(provider.todos.single.priority, TodoPriority.high);
    expect(provider.controller.text, isEmpty);
    final original = provider.todos.single;
    provider.toggleTodoStatus(0, true);
    expect(provider.todos.single.completed, isTrue);
    expect(original.completed, isFalse);
    expect(() => provider.todos.clear(), throwsUnsupportedError);
    provider.removeTodo(0);
    expect(provider.todos, isEmpty);
    expect(notifications, 4);
  });

  testWidgets('Consumer updates form priority, tasks and completion', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Nothing to do!'), findsOneWidget);
    await tester.tap(find.byTooltip('Add todo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SAVE'));
    await tester.pumpAndSettle();
    expect(find.text('Input field must not be empty'), findsOneWidget);
    await tester.tap(find.text('CLOSE'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Study Flutter');
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is Radio<TodoPriority> && widget.value == TodoPriority.high,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('SAVE'));
    await tester.pumpAndSettle();
    expect(find.text('Study Flutter'), findsOneWidget);
    expect(find.text('Priority: High'), findsOneWidget);
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
    await tester.tap(find.byTooltip('Delete Study Flutter'));
    await tester.pumpAndSettle();
    expect(find.text('Nothing to do!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
