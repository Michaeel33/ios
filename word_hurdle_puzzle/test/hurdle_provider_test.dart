import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:word_hurdle_puzzle/hurdle_provider.dart';

class FirstRandom implements Random {
  @override
  int nextInt(int max) => 0;
  @override
  bool nextBool() => false;
  @override
  double nextDouble() => 0;
}

HurdleProvider newGame() => HurdleProvider(
  random: FirstRandom(),
  dictionary: ['apple', 'grape', 'stone', 'legal'],
)..init();

void enter(HurdleProvider provider, String word) {
  for (final letter in word.split('')) {
    provider.inputLetter(letter);
  }
}

void main() {
  test('Real dictionary generates 30 empty tiles and a valid target', () {
    final provider = HurdleProvider()..init();
    addTearDown(provider.dispose);
    expect(provider.hurdleBoard.length, 30);
    expect(provider.targetWord.length, 5);
    expect(provider.totalWords, contains(provider.targetWord.toLowerCase()));
    expect(provider.hurdleBoard.every((tile) => tile.letter.isEmpty), isTrue);
  });

  test(
    'Input is bounded and repeated initialization preserves the current game',
    () {
      final provider = newGame();
      addTearDown(provider.dispose);
      provider.inputLetter('!');
      provider.inputLetter('AB');
      expect(provider.count, 0);
      enter(provider, 'grapes');
      expect(provider.rowInputs.join(), 'GRAPE');
      expect(provider.index, 5);
      provider.init();
      expect(provider.rowInputs.join(), 'GRAPE');
      expect(provider.targetWord, 'APPLE');
      provider.deleteLetter();
      expect(provider.hurdleBoard[4].letter, isEmpty);
      expect(provider.index, 4);
      for (var i = 0; i < 10; i++) {
        provider.deleteLetter();
      }
      expect(provider.count, 0);
      expect(provider.index, 0);
    },
  );

  test('Incomplete and unknown words never spend an attempt', () {
    final provider = newGame();
    addTearDown(provider.dispose);
    enter(provider, 'app');
    provider.checkAnswer();
    expect(provider.attempts, 0);
    expect(provider.count, 3);
    provider.deleteLetter();
    provider.deleteLetter();
    provider.deleteLetter();
    enter(provider, 'zzzzz');
    expect(provider.isValidWord, isFalse);
    provider.checkAnswer();
    expect(provider.attempts, 0);
    expect(provider.count, 5);
  });

  test(
    'Wrong guesses mark presence and absence without duplicate excluded keys',
    () {
      final provider = newGame();
      addTearDown(provider.dispose);
      enter(provider, 'grape');
      provider.checkAnswer();
      expect(provider.attempts, 1);
      expect(provider.count, 0);
      expect(provider.index, 5);
      expect(provider.hurdleBoard[0].doesNotExistInTarget, isTrue);
      expect(provider.hurdleBoard[1].doesNotExistInTarget, isTrue);
      expect(provider.hurdleBoard[2].existsInTarget, isTrue);
      expect(provider.hurdleBoard[3].existsInTarget, isTrue);
      expect(provider.hurdleBoard[4].existsInTarget, isTrue);
      expect(provider.excludedLetters, unorderedEquals(['G', 'R']));
      provider.deleteLetter();
      expect(provider.hurdleBoard[4].letter, 'E');
      enter(provider, 'grape');
      provider.checkAnswer();
      expect(provider.excludedLetters.length, 2);
      expect(provider.hurdleBoard[5].letter, 'G');
    },
  );

  test('Exactly six wrong guesses lose and further input cannot overflow', () {
    final provider = newGame();
    addTearDown(provider.dispose);
    for (var attempt = 0; attempt < 6; attempt++) {
      expect(provider.noAttemptsLeft, isFalse);
      enter(provider, 'grape');
      provider.checkAnswer();
    }
    expect(provider.attempts, 6);
    expect(provider.noAttemptsLeft, isTrue);
    expect(provider.wins, isFalse);
    expect(provider.index, 30);
    provider.inputLetter('A');
    provider.deleteLetter();
    provider.checkAnswer();
    expect(provider.index, 30);
    expect(provider.hurdleBoard.last.letter, 'E');
  });

  test(
    'A correct sixth guess wins, then reset clears all state and changes word',
    () {
      final provider = newGame();
      addTearDown(provider.dispose);
      for (var i = 0; i < 5; i++) {
        enter(provider, 'grape');
        provider.checkAnswer();
      }
      enter(provider, 'apple');
      provider.checkAnswer();
      expect(provider.wins, isTrue);
      expect(provider.noAttemptsLeft, isFalse);
      expect(provider.attempts, 6);
      expect(
        provider.hurdleBoard.skip(25).every((tile) => tile.existsInTarget),
        isTrue,
      );
      provider.reset();
      expect(provider.targetWord, 'GRAPE');
      expect(provider.attempts, 0);
      expect(provider.index, 0);
      expect(provider.rowInputs, isEmpty);
      expect(provider.excludedLetters, isEmpty);
      expect(provider.isGameOver, isFalse);
      expect(provider.hurdleBoard.length, 30);
      expect(
        provider.hurdleBoard.every(
          (tile) =>
              tile.letter.isEmpty &&
              !tile.existsInTarget &&
              !tile.doesNotExistInTarget,
        ),
        isTrue,
      );
    },
  );
}
