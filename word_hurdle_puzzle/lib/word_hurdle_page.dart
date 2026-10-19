import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'helper_functions.dart';
import 'hurdle_provider.dart';
import 'keyboard_view.dart';
import 'wordle_view.dart';

class WordHurdlePage extends StatefulWidget {
  const WordHurdlePage({super.key});

  @override
  State<WordHurdlePage> createState() => _WordHurdlePageState();
}

class _WordHurdlePageState extends State<WordHurdlePage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<HurdleProvider>().init();
  }

  void _handleInput(HurdleProvider provider) {
    if (provider.isGameOver) return;
    if (!provider.shouldCheckForAnswer) {
      showMsg(context, 'Enter all 5 letters');
      return;
    }
    if (!provider.isValidWord) {
      showMsg(context, 'Not a word in my dictionary');
      return;
    }
    provider.checkAnswer();
    if (provider.wins || provider.noAttemptsLeft) {
      showResult(
        context: context,
        title: provider.wins ? 'You Win!!!' : 'You lost!!',
        body: 'The word was ${provider.targetWord}',
        onPlayAgain: () {
          Navigator.pop(context);
          provider.reset();
        },
        onCancel: () => Navigator.pop(context),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HurdleProvider>(
      builder: (context, provider, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Word Hurdle'),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: 'New game',
              onPressed: provider.reset,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  KeyboardView(
                    excludedLetters: provider.excludedLetters,
                    enabled: !provider.isGameOver,
                    onPressed: provider.inputLetter,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: provider.isGameOver
                                ? null
                                : provider.deleteLetter,
                            child: const Text('DELETE'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: provider.isGameOver
                                ? null
                                : () => _handleInput(provider),
                            child: const Text('SUBMIT'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                    child: Text(
                      provider.isGameOver
                          ? '${provider.wins ? "You won!" : "No attempts left."} Word: ${provider.targetWord}'
                          : 'Guess the 5-letter word • Attempt ${provider.attempts + 1}/${provider.totalAttempts}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final boardWidth = min(
                          constraints.maxWidth * 0.70,
                          min(
                            380.0,
                            max(140.0, (constraints.maxHeight - 1) / 1.2),
                          ),
                        );
                        return Center(
                          child: SizedBox(
                            width: boardWidth,
                            height: min(
                              constraints.maxHeight,
                              boardWidth * 1.2 + 1,
                            ),
                            child: GridView.builder(
                              key: const ValueKey('hurdle-board'),
                              padding: EdgeInsets.zero,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 5,
                                    mainAxisSpacing: 4,
                                    crossAxisSpacing: 4,
                                  ),
                              itemCount: provider.hurdleBoard.length,
                              itemBuilder: (context, index) => WordleView(
                                key: ValueKey('tile-$index'),
                                wordle: provider.hurdleBoard[index],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      'Light tile: letter in word • Grey/red: letter absent',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
