import 'dart:math';

import 'package:flutter/material.dart';

import 'data/questions.dart';
import 'models/answer_result.dart';
import 'questions_screen.dart';
import 'results_screen.dart';
import 'start_screen.dart';

enum QuizStage { start, questions, results }

class Quiz extends StatefulWidget {
  const Quiz({super.key});

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  final Random _random = Random();
  final List<String> _selectedAnswers = [];
  QuizStage _stage = QuizStage.start;
  List<String> _answerOrder = [];

  void _startQuiz() {
    setState(() {
      _selectedAnswers.clear();
      _answerOrder = questions.first.shuffledAnswers(_random);
      _stage = QuizStage.questions;
    });
  }

  void _selectAnswer(String answer) {
    if (_stage != QuizStage.questions) return;
    setState(() {
      _selectedAnswers.add(answer);
      if (_selectedAnswers.length == questions.length) {
        _stage = QuizStage.results;
      } else {
        _answerOrder = questions[_selectedAnswers.length].shuffledAnswers(
          _random,
        );
      }
    });
  }

  List<AnswerResult> get _results => questions.asMap().entries.map((entry) {
    return AnswerResult(
      number: entry.key + 1,
      question: entry.value,
      selectedAnswer: _selectedAnswers[entry.key],
    );
  }).toList();

  @override
  Widget build(BuildContext context) {
    final Widget screen = switch (_stage) {
      QuizStage.start => StartScreen(onStart: _startQuiz),
      QuizStage.questions => QuestionsScreen(
        question: questions[_selectedAnswers.length],
        answers: _answerOrder,
        questionNumber: _selectedAnswers.length + 1,
        totalQuestions: questions.length,
        onAnswer: _selectAnswer,
      ),
      QuizStage.results => ResultsScreen(
        results: _results,
        onRestart: _startQuiz,
      ),
    };
    return Scaffold(body: screen);
  }
}
