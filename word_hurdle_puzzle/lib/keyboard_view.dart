import 'package:flutter/material.dart';

const keyList = [
  ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
  ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
  ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
];

class KeyboardView extends StatelessWidget {
  const KeyboardView({
    super.key,
    required this.excludedLetters,
    required this.onPressed,
    this.enabled = true,
  });

  final List<String> excludedLetters;
  final ValueChanged<String> onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final row in keyList)
              Row(
                children: row
                    .map(
                      (letter) => VirtualKey(
                        key: ValueKey('key-$letter'),
                        letter: letter,
                        excluded: excludedLetters.contains(letter),
                        enabled: enabled,
                        onPress: onPressed,
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class VirtualKey extends StatelessWidget {
  const VirtualKey({
    super.key,
    required this.letter,
    required this.excluded,
    required this.onPress,
    this.enabled = true,
  });

  final String letter;
  final bool excluded;
  final ValueChanged<String> onPress;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: excluded ? Colors.red.shade800 : Colors.black,
            foregroundColor: Colors.white,
            disabledBackgroundColor: excluded
                ? Colors.red.shade900
                : Colors.black38,
            disabledForegroundColor: Colors.white54,
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 42),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          onPressed: enabled ? () => onPress(letter) : null,
          child: Text(letter, style: const TextStyle(fontSize: 15)),
        ),
      ),
    );
  }
}
