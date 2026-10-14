import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const DiceApp());
}

class DiceApp extends StatelessWidget {
  const DiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roll the Dice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF4C76A),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF172235),
        useMaterial3: true,
      ),
      home: const DiceScreen(),
    );
  }
}

class DiceScreen extends StatefulWidget {
  const DiceScreen({super.key});

  @override
  State<DiceScreen> createState() => _DiceScreenState();
}

class _DiceScreenState extends State<DiceScreen> {
  final Random _random = Random();
  int _diceValue = 1;
  bool _hasRolled = false;

  void _rollDice() {
    setState(() {
      // nextInt(6) returns 0–5. Adding 1 gives the required range 1–6.
      _diceValue = _random.nextInt(6) + 1;
      _hasRolled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double diceSize = (constraints.maxWidth * 0.6)
                .clamp(120.0, 240.0)
                .toDouble();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: max(0.0, constraints.maxHeight - 48),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Roll the Dice',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFF8E9),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Jeden klik. Jeden náhodný hod.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFFB7C2D3),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Center(
                          child: Image.asset(
                            'assets/images/dice-$_diceValue.png',
                            width: diceSize,
                            height: diceSize,
                            semanticLabel: 'Kocka: $_diceValue',
                          ),
                        ),
                        const SizedBox(height: 28),
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            _hasRolled
                                ? 'Hodená hodnota: $_diceValue'
                                : 'Pripravený hodiť?',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFFF8E9),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        FilledButton.icon(
                          onPressed: _rollDice,
                          icon: const Icon(Icons.casino_outlined),
                          label: const Text('Hodiť kockou'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFF4C76A),
                            foregroundColor: const Color(0xFF172235),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Každá strana má rovnakú šancu: 1 zo 6.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFB7C2D3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
