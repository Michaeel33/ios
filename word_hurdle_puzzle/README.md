# Word Hurdle Puzzle

Flutter hra podľa jednotlivých kapitol zadania. Hráč háda päťpísmenové anglické slovo počas najviac šiestich pokusov.

## Spustenie

```powershell
flutter pub get
flutter devices
flutter run -d emulator-5554
```

Emulátor musí byť spustený. Ak má iné ID, použi ID uvedené vo flutter devices.

## Ovládanie a pravidlá

- Klikaním na klávesnicu vlož päť písmen. DELETE odstráni posledné písmeno aktuálneho pokusu.
- SUBMIT overí slovo v slovníku balíčka english_words. Neúplné a neznáme slová nespotrebujú pokus.
- Svetlé políčko znamená prítomnosť písmena v cieľovom slove. Sivé políčko a červený kláves znamenajú neprítomnosť.
- Farbenie podľa zadania vyhodnocuje prítomnosť písmena; nerozlišuje jeho presnú pozíciu ani počet výskytov.
- Presná zhoda celého slova znamená výhru. Šiesty nesprávny platný pokus znamená prehru.
- Play Again obnoví hru s novým slovom. Quit zatvorí výsledkový dialóg. Novú hru možno spustiť aj ikonou v hlavičke.

## Súbory

- lib/main.dart: registrácia ChangeNotifierProvider, tmavá téma a EasyLoading.
- lib/hurdle_provider.dart: slovník, vstup, vyhodnotenie, pokusy a reset.
- lib/wordle.dart: model jedného políčka.
- lib/word_hurdle_page.dart: StatefulWidget a herná obrazovka s Consumer.
- lib/wordle_view.dart: kruhové políčko s amber obrysom.
- lib/keyboard_view.dart: KeyboardView a VirtualKey s callbackmi.
- lib/helper_functions.dart: SnackBar a výsledkový dialóg.

Slovník english_words nie je úplný slovník angličtiny. V debug režime sa cieľové slovo vypisuje do konzoly podľa návodu. V release režime sa nevypisuje.

## Overenie

```powershell
flutter analyze
flutter test
flutter build apk --debug
```

Testy pokrývajú hranice vstupu, mazanie, validáciu slov, šiesty pokus, farbenie, reštart, dialógy, Provider, EasyLoading aj responzívne rozloženie.
