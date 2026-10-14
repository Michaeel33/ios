import 'dart:math';

class QuizQuestion {
  const QuizQuestion({required this.text, required this.answers});

  final String text;
  // The first answer in the source data is correct.
  final List<String> answers;

  String get correctAnswer => answers.first;

  List<String> shuffledAnswers(Random random) {
    // Copy before shuffling so the original correct answer stays unchanged.
    return List<String>.of(answers)..shuffle(random);
  }
}
