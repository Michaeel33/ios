import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:word_hurdle_puzzle/hurdle_provider.dart';
import 'package:word_hurdle_puzzle/main.dart';
import 'package:word_hurdle_puzzle/word_hurdle_page.dart';

import 'hurdle_provider_test.dart' show FirstRandom;

Widget testApp(HurdleProvider provider) =>
    ChangeNotifierProvider.value(value: provider, child: const MyApp());

Future<void> typeWord(WidgetTester tester, String word) async {
  for (final letter in word.split('')) {
    await tester.tap(find.byKey(ValueKey('key-$letter')));
    await tester.pump();
  }
}

void main() {
  testWidgets('Real app registers its Provider and EasyLoading works', (
    tester,
  ) async {
    await tester.pumpWidget(const WordHurdleApp());
    await tester.pumpAndSettle();
    expect(find.byType(WordHurdlePage), findsOneWidget);
    expect(find.text('Word Hurdle'), findsOneWidget);
    EasyLoading.showInfo('Ready');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Ready'), findsOneWidget);
    final dismissed = EasyLoading.dismiss(animation: false);
    await tester.pumpAndSettle();
    await dismissed;
    expect(find.text('Ready'), findsNothing);
  });

  testWidgets(
    'Keyboard, validation, win dialog, replay and Quit are functional',
    (tester) async {
      final provider = HurdleProvider(
        random: FirstRandom(),
        dictionary: ['apple', 'grape'],
      );
      addTearDown(provider.dispose);
      await tester.pumpWidget(testApp(provider));
      await tester.pumpAndSettle();
      await tester.tap(find.text('SUBMIT'));
      await tester.pumpAndSettle();
      expect(find.text('Enter all 5 letters'), findsOneWidget);
      await typeWord(tester, 'ZZZZZ');
      await tester.tap(find.text('SUBMIT'));
      await tester.pumpAndSettle();
      expect(find.text('Not a word in my dictionary'), findsOneWidget);
      expect(provider.attempts, 0);
      for (var i = 0; i < 5; i++) {
        await tester.tap(find.text('DELETE'));
        await tester.pump();
      }
      await typeWord(tester, 'APPLE');
      await tester.tap(find.text('SUBMIT'));
      await tester.pumpAndSettle();
      expect(find.text('You Win!!!'), findsOneWidget);
      expect(find.text('The word was APPLE'), findsOneWidget);
      await tester.tap(find.text('Play Again'));
      await tester.pumpAndSettle();
      expect(provider.isGameOver, isFalse);
      expect(provider.attempts, 0);
      expect(provider.targetWord, 'GRAPE');
      await typeWord(tester, 'GRAPE');
      await tester.tap(find.text('SUBMIT'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Quit'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(provider.isGameOver, isTrue);
      expect(
        tester
            .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, 'SUBMIT'),
            )
            .onPressed,
        isNull,
      );
      await tester.tap(find.byTooltip('New game'));
      await tester.pumpAndSettle();
      expect(provider.isGameOver, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Six wrong answers show loss dialog without an extra attempt', (
    tester,
  ) async {
    final provider = HurdleProvider(
      random: FirstRandom(),
      dictionary: ['apple', 'grape'],
    );
    addTearDown(provider.dispose);
    await tester.pumpWidget(testApp(provider));
    await tester.pumpAndSettle();
    for (var i = 0; i < 6; i++) {
      await typeWord(tester, 'GRAPE');
      await tester.tap(find.text('SUBMIT'));
      await tester.pumpAndSettle();
      if (i < 5) expect(find.byType(AlertDialog), findsNothing);
    }
    expect(find.text('You lost!!'), findsOneWidget);
    expect(find.text('The word was APPLE'), findsOneWidget);
    await tester.tap(find.text('Play Again'));
    await tester.pumpAndSettle();
    expect(provider.attempts, 0);
    expect(provider.excludedLetters, isEmpty);
    expect(tester.takeException(), isNull);
  });

  for (final size in [const Size(320, 480), const Size(844, 390)]) {
    testWidgets(
      'Layout works at $size and does not reset on dependency changes',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final provider = HurdleProvider(
          random: FirstRandom(),
          dictionary: ['apple', 'grape'],
        );
        addTearDown(provider.dispose);
        await tester.pumpWidget(testApp(provider));
        await tester.pumpAndSettle();
        await typeWord(tester, 'A');
        expect(provider.count, 1);
        tester.view.physicalSize = Size(size.width + 10, size.height);
        await tester.pumpAndSettle();
        expect(provider.count, 1);
        expect(provider.targetWord, 'APPLE');
        expect(tester.takeException(), isNull);
      },
    );
  }
}
