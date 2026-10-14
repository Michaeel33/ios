import 'package:flutter/material.dart';

import 'widgets/screen_layout.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return ScreenLayout(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.quiz_outlined, size: 92, color: Color(0xFF5355D9)),
          const SizedBox(height: 28),
          const Text(
            'Ako dobre poznáš Flutter?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Color(0xFF26263F),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '6 otázok • 4 možnosti • 1 správna odpoveď',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Color(0xFF6B6B85)),
          ),
          const SizedBox(height: 12),
          const Text(
            'Vyber odpoveď a automaticky pokračuj na ďalšiu otázku. Na konci uvidíš celý prehľad.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 36),
          FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start Quiz'),
          ),
        ],
      ),
    );
  }
}
