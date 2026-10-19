import 'dart:collection';
import 'dart:math';

import 'package:english_words/english_words.dart' as words;
import 'package:flutter/foundation.dart';

import 'wordle.dart';

class HurdleProvider extends ChangeNotifier {
  HurdleProvider({Random? random, List<String>? dictionary})
    : _random = random ?? Random.secure(),
      _dictionary = dictionary == null ? null : List.unmodifiable(dictionary);

  final Random _random;
  final List<String>? _dictionary;
  final List<String> _rowInputs = [];
  final Set<String> _excludedLetters = {};
  List<String> _totalWords = [];
  Set<String> _validWords = {};
  List<Wordle> _hurdleBoard = [];
  String _targetWord = '';
  bool _initialized = false;
  bool _wins = false;
  int _attempts = 0;

  final int lettersPerRow = 5;
  final int totalAttempts = 6;

  UnmodifiableListView<String> get totalWords =>
      UnmodifiableListView(_totalWords);
  UnmodifiableListView<String> get rowInputs =>
      UnmodifiableListView(_rowInputs);
  UnmodifiableListView<Wordle> get hurdleBoard =>
      UnmodifiableListView(_hurdleBoard);
  List<String> get excludedLetters => List.unmodifiable(_excludedLetters);
  String get targetWord => _targetWord;
  int get attempts => _attempts;
  int get count => _rowInputs.length;
  int get index => _attempts * lettersPerRow + count;
  bool get wins => _wins;
  bool get noAttemptsLeft => !_wins && _attempts >= totalAttempts;
  bool get isGameOver => wins || noAttemptsLeft;
  bool get shouldCheckForAnswer => count == lettersPerRow;
  bool get isValidWord => _validWords.contains(_rowInputs.join().toLowerCase());
  bool get isAValidWord => isValidWord;

  // Called from didChangeDependencies; repeated calls must not restart a game.
  void init() {
    if (_initialized) return;
    _totalWords = (_dictionary ?? words.all)
        .map((word) => word.toLowerCase())
        .where((word) => RegExp(r'^[a-z]{5}$').hasMatch(word))
        .toSet()
        .toList();
    if (_totalWords.isEmpty) {
      throw StateError('The dictionary must contain a five-letter word.');
    }
    _validWords = _totalWords.toSet();
    generateBoard();
    generateRandomWord();
    _initialized = true;
  }

  void generateBoard() {
    _hurdleBoard = List.generate(
      totalAttempts * lettersPerRow,
      (_) => const Wordle(letter: ''),
    );
  }

  void generateRandomWord() {
    final previous = _targetWord.toLowerCase();
    final choices = _totalWords.length > 1
        ? _totalWords.where((word) => word != previous).toList()
        : _totalWords;
    _targetWord = choices[_random.nextInt(choices.length)].toUpperCase();
    if (kDebugMode) debugPrint('Target word: $_targetWord');
  }

  void inputLetter(String letter) {
    final value = letter.toUpperCase();
    if (!_initialized ||
        isGameOver ||
        count >= lettersPerRow ||
        !RegExp(r'^[A-Z]$').hasMatch(value)) {
      return;
    }
    _hurdleBoard[index] = Wordle(letter: value);
    _rowInputs.add(value);
    notifyListeners();
  }

  void deleteLetter() {
    if (!_initialized || isGameOver || _rowInputs.isEmpty) return;
    _hurdleBoard[index - 1] = const Wordle(letter: '');
    _rowInputs.removeLast();
    notifyListeners();
  }

  void checkAnswer() {
    if (!_initialized || isGameOver || !shouldCheckForAnswer || !isValidWord) {
      return;
    }
    final input = _rowInputs.join();
    _markLettersOnBoard();
    _wins = input == _targetWord;
    _goToNextRow();
    notifyListeners();
  }

  // The course rules mark presence, not exact position or occurrence counts.
  void _markLettersOnBoard() {
    final start = _attempts * lettersPerRow;
    for (var offset = 0; offset < lettersPerRow; offset++) {
      final letter = _rowInputs[offset];
      final exists = _targetWord.contains(letter);
      _hurdleBoard[start + offset] = Wordle(
        letter: letter,
        existsInTarget: exists,
        doesNotExistInTarget: !exists,
      );
      if (!exists) _excludedLetters.add(letter);
    }
  }

  void _goToNextRow() {
    _attempts++;
    _rowInputs.clear();
  }

  void reset() {
    if (!_initialized) {
      init();
    } else {
      _rowInputs.clear();
      _excludedLetters.clear();
      _attempts = 0;
      _wins = false;
      generateBoard();
      generateRandomWord();
    }
    notifyListeners();
  }
}
