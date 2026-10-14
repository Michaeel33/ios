import 'package:flutter/material.dart';

import 'models/quiz_question.dart';
import 'widgets/answer_button.dart';
import 'widgets/screen_layout.dart';

class QuestionsScreen extends StatelessWidget {
  const QuestionsScreen({
    super.key,
    required this.question,
    required this.answers,
    required this.questionNumber,
    required this.totalQuestions,
    required this.onAnswer,
  });

  final QuizQuestion question;
  final List<String> answers;
  final int questionNumber;
  final int totalQuestions;
  final ValueChanged<String> onAnswer;

  @override
  Widget build(BuildContext context) {
    return ScreenLayout(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'FLUTTER KVÍZ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5355D9),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Otázka $questionNumber / $totalQuestions',
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: questionNumber / totalQuestions,
            minHeight: 6,
            borderRadius: BorderRadius.circular(8),
            backgroundColor: const Color(0xFFE4E4F5),
          ),
          const SizedBox(height: 32),
          Text(
            question.text,
            style: const TextStyle(
              fontSize: 28,
              height: 1.25,
              fontWeight: FontWeight.bold,
              color: Color(0xFF26263F),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Vyber jednu odpoveď.',
            style: TextStyle(color: Color(0xFF6B6B85), fontSize: 16),
          ),
          const SizedBox(height: 28),
          ...answers.asMap().entries.map(
            (entry) => AnswerButton(
              key: ValueKey('$questionNumber-${entry.value}'),
              text: entry.value,
              number: entry.key + 1,
              onTap: () => onAnswer(entry.value),
            ),
          ),
        ],
      ),
    );
  }
}
