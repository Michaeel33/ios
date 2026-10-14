# Quiz App

Interaktívny kvíz so šiestimi otázkami o Flutteri.

## Spustenie

Otvor celý priečinok Quiz-App vo VS Code. V termináli:

```powershell
flutter pub get
flutter devices
flutter run -d emulator-5554
```

Použi ID emulátora z výpisu `flutter devices`.
Ak sa emulátor nespustí cez ponuku Flutter: Launch Emulator, v samostatnom
termináli môžeš použiť fungujúci príkaz z tvojho prostredia:

```powershell
& "C:\Users\fatha\Documents\Codex\AndroidSDK\emulator\emulator.exe" -avd Flutter_Pixel -no-snapshot-load
```

Terminál emulátora nechaj otvorený a aplikáciu spusti v ďalšom termináli.

## Požiadavky zadania

- `start_screen.dart`: úvod a tlačidlo Start Quiz.
- `questions_screen.dart`: otázka, priebeh a dynamicky vytvorené tlačidlá cez `map()` a `...`.
- `results_screen.dart`: počet správnych odpovedí, percentá, prehľad a Restart Quiz.
- `quiz.dart`: StatefulWidget a setState(), zoznam vybraných odpovedí, prechod medzi tromi obrazovkami a reštart.
- `data/questions.dart`: štruktúrovaný zoznam otázok.
- `models/quiz_question.dart`: dátový model a `shuffle()` kópie odpovedí.
- `models/answer_result.dart`: model výsledku jednej otázky.
- `questions_summary.dart`: mapovanie všetkých odpovedí a zobrazenie správnej odpovede pri chybe.
- `widgets/answer_button.dart`: opakovane použiteľný widget s callbackom.
- `widgets/screen_layout.dart`: spoločné responzívne a posúvateľné rozloženie.

Prvá odpoveď v zdrojových dátach je správna. Na obrazovke sa poradie premieša;
zdrojový zoznam sa nemení. Po kliknutí sa automaticky zobrazí ďalšia otázka.
Skóre sa počíta cez `where(...).length`. Reštart rovno spustí nový kvíz od prvej otázky.

## Overenie

```powershell
flutter analyze
flutter test
```

Testy overujú premiešanie bez zmeny dát, správne skóre pri zmiešaných odpovediach,
reštart, druhý priechod a malé rozlíšenie.

## Odovzdanie

Git repozitár si riešiš sám. Na odovzdanie sú potrebné aspoň dve snímky
z Android emulátora: Questions Screen a Results Screen. Ak sú snímky
v priečinku screenshots, pochádzajú zo spustenej aplikácie.
Inak ich vytvor tlačidlom fotoaparátu na bočnom paneli emulátora.
