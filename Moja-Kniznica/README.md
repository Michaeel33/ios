# Moja knižnica

Vlastná Flutter aplikácia na evidenciu kníh. Pridávaj knihy, sleduj čítanie,
zapisuj poznámky a hodnotenia. Dáta sa ukladajú do lokálneho JSON súboru.

## Spustenie

Otvor celý priečinok Moja-Kniznica vo VS Code. Zapni Android emulátor.
V termináli projektu:

```powershell
flutter pub get
flutter devices
flutter run -d emulator-5554
```

Ak má emulátor iné ID, použi ho podľa flutter devices. Tento projekt obsahuje
Android platformu; pri spustení vyber Android emulátor, nie Chrome.
Na prvé stiahnutie balíčkov a zostavenie je potrebný internet.
Samotná knižnica potom funguje offline.

## Používanie

1. Na hlavnej obrazovke klikni na Pridať knihu.
2. Zadaj názov a autora; vyber stav, hodnotenie a voliteľné poznámky.
3. Ulož knihu. Na hlavnej obrazovke sa dá vyhľadať podľa názvu alebo autora.
4. Použi filtre Všetky, Chcem čítať, Čítam a Prečítané.
5. Kliknutím na knihu otvor detail. Tlačidlo Upraviť knihu otvorí rovnaký formulár
   s predvyplnenými údajmi. Šípka vľavo hore sa vráti na predchádzajúcu obrazovku.
6. Odstránenie knihy vyžaduje potvrdenie.

Nová knižnica je prázdna, údaje si zadáva používateľ. Ak máš aktívny filter,
nová kniha s iným stavom nebude v aktuálnom zozname; zobrazí sa po výbere Všetky.

## Splnenie požiadaviek

| Požiadavka | Implementácia |
| --- | --- |
| Minimálne 3 obrazovky | LibraryScreen, BookDetailScreen, BookFormScreen |
| Navigator.push() a Navigator.pop() | Zoznam → detail → úprava; uloženie vracia výsledok cez pop(context, true) |
| Formulár a vstup | Názov, autor, stav, hodnotenie, poznámky; validácia povinných údajov |
| Provider | LibraryProvider extends ChangeNotifier; ChangeNotifierProvider v main.dart; Consumer v zozname a detaile |
| Vlastný model | Nemenný Book, ReadingStatus, serializácia toJson/fromJson |
| Dáta a callbacky | ID do detailu, Book do formulára, onTap v BookCard, výsledok uloženia späť cez Navigator |
| Responzívne rozloženie | Row, Column, Expanded, Wrap, ListView, SingleChildScrollView a maximálna šírka obsahu |
| Externá funkcionalita | dart:io + path_provider: čítanie a zápis JSON súboru na zariadení |

## Štruktúra

```text
lib/
  main.dart
  models/book.dart
  providers/library_provider.dart
  services/library_storage.dart
  widgets/book_widgets.dart
  screens/library_screen.dart
  screens/book_detail_screen.dart
  screens/book_form_screen.dart
test/library_test.dart
android/
pubspec.yaml
```

Provider spravuje knihy, vyhľadávanie, filter a asynchrónne načítanie/uloženie.
Lokálny stav rozpracovaného formulára (dropdowny a kontroléry) patrí jeho
StatefulWidgetu; potvrdené údaje knihy spravuje iba Provider.

## Lokálne ukladanie

LibraryStorage je rozhranie a JsonLibraryStorage jeho súborová implementácia.
path_provider nájde súkromný dokumentový priečinok aplikácie. Súbor library.json
obsahuje verziu formátu a zoznam kníh. Nové dáta sa najprv zapíšu do dočasného
súboru a po dokončení zápisu nahradia predchádzajúci JSON.

Provider potvrdí zmenu v pamäti až po úspešnom zápise. Pri chybe zápisu zobrazí
hlášku a formulár zostane otvorený. Neplatný existujúci JSON zobrazí chybu
načítania a aplikácia ho automaticky neprepíše.

Údaje prežijú bežné zavretie a opätovné spustenie. Vymazanie dát aplikácie alebo
jej odinštalovanie vymaže aj knižnicu. Nejde o synchronizáciu s cloudom.
Android nepotrebuje povolenie na prístup do verejnej galérie či úložiska.

## Overenie

```powershell
flutter analyze
flutter test
```

Pripravené testy overujú:
- zápis, opätovné načítanie a zmenu JSON súboru,
- ochranu poškodeného súboru pred prepísaním,
- vyhľadávanie, filtre, úpravu a neúspešné ukladanie,
- tri obrazovky, validáciu formulára a návrat po úprave,
- malé rozlíšenie a posúvateľný formulár.

V prostredí asistenta zlyhalo spustenie Dart runtime ešte pred načítaním projektu.
Testy, analýza ani Android zostavenie preto zatiaľ nemajú potvrdený úspešný výsledok.
Spusti ich vo svojom termináli uvedenými príkazmi.

## Screenshoty na odovzdanie

Screenshoty zo zariadenia zatiaľ nie sú súčasťou projektu. Po spustení pridaj
knihu a zachyť hlavnú obrazovku, detail knihy a formulár. V Android emulátore
použi tlačidlo fotoaparátu na bočnom paneli.

Git repozitár a odovzdanie riešiš sám.
