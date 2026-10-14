import 'package:flutter/material.dart';

import 'models/answer_result.dart';
import 'questions_summary.dart';
import 'widgets/screen_layout.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({
    super.key,
    required this.results,
    required this.onRestart,
  });

  final List<AnswerResult> results;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final correctCount = results.where((result) => result.isCorrect).length;
    final percentage = results.isEmpty
        ? 0
        : (correctCount / results.length * 100).round();
    return ScreenLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.emoji_events_outlined,
            size: 56,
            color: Color(0xFF5355D9),
          ),
          const SizedBox(height: 12),
          const Text(
            'Kvíz dokončený!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            '$correctCount / ${results.length}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5355D9),
            ),
          ),
          Text(
            '$percentage % správnych odpovedí',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onRestart,
            icon: const Icon(Icons.refresh),
            label: const Text('Restart Quiz'),
          ),
          const SizedBox(height: 28),
          const Text(
            'Tvoje odpovede',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          QuestionsSummary(results: results),
        ],
      ),
    );
  }
}
