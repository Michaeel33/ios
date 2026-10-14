import 'package:flutter/material.dart';

import 'models/answer_result.dart';

class QuestionsSummary extends StatelessWidget {
  const QuestionsSummary({super.key, required this.results});

  final List<AnswerResult> results;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: results.map((result) {
        final color = result.isCorrect
            ? const Color(0xFF16744A)
            : const Color(0xFFAB354E);
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE4E4F0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Text(
                    '${result.number}',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.question.text,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${result.isCorrect ? "✓ Správne" : "✗ Nesprávne"}: ${result.selectedAnswer}',
                        style: TextStyle(color: color, height: 1.4),
                      ),
                      if (!result.isCorrect) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Správna odpoveď: ${result.question.correctAnswer}',
                          style: const TextStyle(
                            color: Color(0xFF16744A),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
