import 'package:flutter/material.dart';

import 'wordle.dart';

class WordleView extends StatelessWidget {
  const WordleView({super.key, required this.wordle});
  final Wordle wordle;

  @override
  Widget build(BuildContext context) {
    final state = wordle.existsInTarget
        ? 'letter is in the word'
        : wordle.doesNotExistInTarget
        ? 'letter is not in the word'
        : 'not checked';
    return Semantics(
      label: wordle.letter.isEmpty ? 'Empty tile' : '${wordle.letter}, $state',
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: wordle.existsInTarget
              ? Colors.white60
              : wordle.doesNotExistInTarget
              ? Colors.blueGrey.shade700
              : null,
          border: Border.all(color: Colors.amber, width: 1.5),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            wordle.letter,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: wordle.existsInTarget
                  ? Colors.black
                  : wordle.doesNotExistInTarget
                  ? Colors.white54
                  : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
