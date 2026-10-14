import '../models/quiz_question.dart';

const questions = <QuizQuestion>[
  QuizQuestion(
    text: 'V akom jazyku sa píšu Flutter aplikácie?',
    answers: ['Dart', 'Kotlin', 'JavaScript', 'Swift'],
  ),
  QuizQuestion(
    text: 'Čo tvorí základ používateľského rozhrania vo Flutteri?',
    answers: ['Widgety', 'SQL tabuľky', 'HTML súbory', 'Serverové endpointy'],
  ),
  QuizQuestion(
    text: 'Ktorý widget má stav, ktorý sa môže počas používania meniť?',
    answers: ['StatefulWidget', 'StatelessWidget', 'SizedBox', 'Padding'],
  ),
  QuizQuestion(
    text: 'Čo robí setState()?',
    answers: [
      'Oznámi zmenu stavu a naplánuje obnovu rozhrania',
      'Uloží aplikáciu do Git repozitára',
      'Stiahne nový Flutter SDK',
      'Vždy otvorí novú obrazovku',
    ],
  ),
  QuizQuestion(
    text: 'Ktorý widget rozloží svoje deti zvislo?',
    answers: ['Column', 'Row', 'Stack', 'Icon'],
  ),
  QuizQuestion(
    text: 'Kde registrujeme lokálne obrázky aplikácie?',
    answers: [
      'V pubspec.yaml',
      'V README.md',
      'V main.dart ako import',
      'V .gitignore',
    ],
  ),
];
