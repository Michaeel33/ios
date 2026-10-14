import 'quiz_question.dart';

class AnswerResult {
  const AnswerResult({
    required this.number,
    required this.question,
    required this.selectedAnswer,
  });

  final int number;
  final QuizQuestion question;
  final String selectedAnswer;

  bool get isCorrect => selectedAnswer == question.correctAnswer;
}
