import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roll_the_dice/main.dart';

void main() {
  testWidgets('A roll updates the displayed value and its local image', (
    tester,
  ) async {
    await tester.pumpWidget(const DiceApp());
    expect(find.text('Pripravený hodiť?'), findsOneWidget);

    final observedValues = <int>{};
    for (var roll = 0; roll < 60; roll++) {
      await tester.tap(find.text('Hodiť kockou'));
      await tester.pumpAndSettle();

      final result = tester.widget<Text>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              (widget.data?.startsWith('Hodená hodnota: ') ?? false),
        ),
      );
      final value = int.parse(result.data!.split(': ').last);
      expect(value, inInclusiveRange(1, 6));
      observedValues.add(value);

      final image = tester.widget<Image>(find.byType(Image));
      expect(
        (image.image as AssetImage).assetName,
        'assets/images/dice-$value.png',
      );
      expect(tester.takeException(), isNull);
    }
    expect(observedValues.length, greaterThan(1));
  });

  testWidgets('The button remains reachable on a small screen', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const DiceApp());
    await tester.ensureVisible(find.text('Hodiť kockou'));
    await tester.tap(find.text('Hodiť kockou'));
    await tester.pumpAndSettle();
    expect(find.text('Pripravený hodiť?'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
