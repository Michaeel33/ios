# Earthquake App

Flutter aplikácia na zobrazenie zemetrasení z verejného USGS Earthquake API. Stav spravuje AppDataProvider a UI používa Consumer.

## Spustenie na Android emulátore

```powershell
flutter pub get
flutter devices
flutter run -d emulator-5554
```

Emulátor musí byť spustený. Ak používa iné ID, nahraď ho podľa flutter devices. Projekt cieli na Android, iOS a web; hlavné overenie prebieha na Androide. Android minSdk je 35 podľa zadania, compileSdk preberá aktuálne Flutter SDK.

## Funkcie

- Zoznam skutočných zemetrasení s miestom, časom a magnitúdou.
- Predvolene včerajší a dnešný deň (UTC), magnitúda aspoň 4, najviac 500 výsledkov.
- Štyri spôsoby triedenia: čas a magnitúda, vzostupne aj zostupne. Každá zmena načíta nové údaje z API.
- Settings: výber začiatku a konca cez kalendár a Update Time Changes. Rozsah zahŕňa oba celé dni; začiatok nesmie byť po konci.
- Earthquakes near me: po povolení polohy použije aktuálne súradnice a okruh 300 km. Mesto sa dopĺňa cez geocoding; pri jeho nedostupnosti sa zobrazia súradnice.
- Na Androide sa používa natívny LocationManager bez vyžadovania Google Location Accuracy. GPS sa zisťuje iba na vyžiadanie pri zapnutí prepínača. Opätovné vypnutie a zapnutie aktualizuje polohu.
- Obnova ikonou alebo potiahnutím zoznamu. Údaje sa načítavajú na vyžiadanie, bez automatického časovača.
- Ošetrené načítanie, prázdny zoznam, výpadok siete, nesprávna odpoveď servera a zamietnutá poloha.

Na obrazovke sa čas udalostí formátuje v časovom pásme zariadenia. Vybrané dátumy pre API sa interpretujú v UTC. Pri aktívnom polohovom filtri môže byť zoznam prázdny, najmä pre magnitúdu aspoň 4.

PAGER alert (green/yellow/orange/red) pochádza priamo z USGS a opisuje odhadovaný dopad. Nie je odvodený z magnitúdy a chýbajúci alert neznamená bezpečnosť. Pri chýbajúcom alerte sa farebný avatar nezobrazuje.

## Štruktúra

- lib/main.dart: MaterialApp, ChangeNotifierProvider, EasyLoading a tmavá téma.
- lib/models/earthquake_model.dart: EarthquakeModel, Features a Properties s fromJson.
- lib/providers/app_data_provider.dart: API, stav, dátumy, triedenie a polohový filter.
- lib/pages/home_page.dart: zoznam, Sort, Refresh a navigácia do Settings.
- lib/settings_page.dart: kalendáre a polohový prepínač.
- lib/services/location_service.dart: oprávnenia, GPS a reverse geocoding.
- lib/utils/helper_functions.dart: dátumy a SnackBar správy.

## Oprávnenia a platformy

Android: INTERNET, ACCESS_COARSE_LOCATION a ACCESS_FINE_LOCATION v hlavnom manifeste. Aplikácia nesleduje polohu na pozadí, preto nepotrebuje ACCESS_BACKGROUND_LOCATION ani background location režim v iOS.

iOS má NSLocationWhenInUseUsageDescription. Pri zostavení na Macu so Swift Package Managerom použi foreground-only konfiguráciu geolocator:

```sh
BYPASS_PERMISSION_LOCATION_ALWAYS=1 flutter build ios
```

iOS zostavenie nemožno overiť na Windows. Reverse geocoding je dostupný na Android/iOS; na webe sa môže použiť súradnicový fallback. Webová poloha vyžaduje bezpečný kontext (localhost alebo HTTPS).

## Overenie

```powershell
flutter analyze
flutter test
flutter build apk --debug
```

Testy overujú JSON vrátane null hodnôt, parametre API, všetky triedenia, dátumový rozsah, prázdne dáta, HTTP chyby, súbežné požiadavky, polohový filter, navigáciu a malé rozlíšenie.

## Zdroje

- USGS API: https://earthquake.usgs.gov/fdsnws/event/1/
- Geolocator: https://pub.dev/packages/geolocator
- Geocoding: https://pub.dev/packages/geocoding


Screenshoty sú zo skutočne spustenej aplikácie v Android emulátore. Mountain View na polohovom screenshote je simulovaná GPS poloha emulátora.

