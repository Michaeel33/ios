# To-Do aplikácia s Providerom

Refaktorovanie pôvodnej aplikácie zo súboru todo_app.zip dodaného k zadaniu.

## Zmeny

- main.dart registruje ChangeNotifierProvider nad celou aplikáciou.
- todo_provider.dart obsahuje TodoProvider extends ChangeNotifier.
- Provider vlastní zoznam úloh, textový kontrolér, prioritu, validáciu a operácie pridania, označenia a odstránenia.
- todo_page.dart je StatelessWidget. Consumer<TodoProvider> obnovuje zoznam aj formulár.
- Pôvodné setState a StatefulBuilder boli odstránené. Zmeny oznamuje notifyListeners().
- Zachované sú texty My Todos, Nothing to do!, What to do?, Select Priority, SAVE a pôvodný validačný dialóg.
- Priority majú názvy Low, Normal a High. Pridané sú ich farby a odstraňovanie úloh.
- Formulár sa posúva a rešpektuje otvorenú klávesnicu.
- Dáta ostávajú v pamäti, ako v pôvodnej aplikácii. Po ukončení aplikácie sa neukladajú.

Model MyTodo je nemenný a zoznam je prístupný iba na čítanie. Zmenu dokončenia
tak môže vykonať iba Provider, ktorý zároveň upozorní Consumer.
Provider pri zrušení uvoľní textový kontrolér.

## Spustenie vo VS Code

Otvor celý priečinok Todo-Provider. V termináli:

```powershell
flutter pub get
flutter devices
flutter run -d emulator-5554
```

Použi aktuálne ID zapnutého Android emulátora z flutter devices.

## Kontrola

```powershell
flutter analyze
flutter test
```

ZIP Todo-Provider-odovzdanie.zip obsahuje presne požadované lib/ a pubspec.yaml.
Celý spustiteľný projekt je v priečinku na ploche; druhý ZIP obsahuje aj platformové súbory a testy.
