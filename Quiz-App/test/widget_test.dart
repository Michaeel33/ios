import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/data/questions.dart';
import 'package:quiz_app/main.dart';
import 'package:quiz_app/models/quiz_question.dart';
import 'package:quiz_app/questions_screen.dart';
import 'package:quiz_app/results_screen.dart';

import 'dart:math';

void main() {
  test('Shuffling preserves source data and all answer choices', () {
    const question = QuizQuestion(text: 'Test', answers: ['A', 'B', 'C', 'D']);
    final shuffled = question.shuffledAnswers(Random(42));
    expect(shuffled, unorderedEquals(question.answers));
    expect(identical(shuffled, question.answers), isFalse);
    expect(question.correctAnswer, 'A');
    expect(question.answers, ['A', 'B', 'C', 'D']);
  });

  testWidgets('Quiz advances, scores mixed answers and restarts cleanly', (
    tester,
  ) async {
    await tester.pumpWidget(const QuizApp());
    await tester.tap(find.text('Start Quiz'));
    await tester.pumpAndSettle();
    for (var i = 0; i < questions.length; i++) {
      expect(
        find.text('Otázka ${i + 1} / ${questions.length}'),
        findsOneWidget,
      );
      final answer = questions[i].answers[i.isEven ? 0 : 1];
      await tester.ensureVisible(find.text(answer));
      await tester.tap(find.text(answer));
      await tester.pumpAndSettle();
    }
    expect(find.byType(ResultsScreen), findsOneWidget);
    expect(find.text('3 / 6'), findsOneWidget);
    expect(find.text('50 % správnych odpovedí'), findsOneWidget);
    final results = tester
        .widget<ResultsScreen>(find.byType(ResultsScreen))
        .results;
    for (var i = 0; i < results.length; i++) {
      expect(results[i].isCorrect, i.isEven);
      expect(results[i].question, questions[i]);
    }
    await tester.tap(find.text('Restart Quiz'));
    await tester.pumpAndSettle();
    expect(find.byType(QuestionsScreen), findsOneWidget);
    expect(find.text('Otázka 1 / 6'), findsOneWidget);
    for (final question in questions) {
      await tester.ensureVisible(find.text(question.correctAnswer));
      await tester.tap(find.text(question.correctAnswer));
      await tester.pumpAndSettle();
    }
    expect(find.text('6 / 6'), findsOneWidget);
    expect(find.text('100 % správnych odpovedí'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('All screens fit a narrow viewport and scroll', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const QuizApp());
    await tester.ensureVisible(find.text('Start Quiz'));
    await tester.tap(find.text('Start Quiz'));
    await tester.pumpAndSettle();
    for (final question in questions) {
      await tester.ensureVisible(find.text(question.correctAnswer));
      await tester.tap(find.text(question.correctAnswer));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    await tester.ensureVisible(find.text(questions.last.text));
    expect(find.text(questions.last.text), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
