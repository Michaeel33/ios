class Wordle {
  const Wordle({
    required this.letter,
    this.existsInTarget = false,
    this.doesNotExistInTarget = false,
  }) : assert(!(existsInTarget && doesNotExistInTarget));

  final String letter;
  final bool existsInTarget;
  final bool doesNotExistInTarget;
}
