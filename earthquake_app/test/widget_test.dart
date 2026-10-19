import 'dart:async';
import 'dart:convert';

import 'package:earthquake_app/main.dart';
import 'package:earthquake_app/models/earthquake_model.dart';
import 'package:earthquake_app/providers/app_data_provider.dart';
import 'package:earthquake_app/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

Map<String, dynamic> feature({
  String id = 'one',
  num? mag = 4,
  String? alert = 'green',
}) => {
  'type': 'Feature',
  'id': id,
  'properties': {
    'mag': mag,
    'place': 'Test region',
    'time': 1700000000000,
    'alert': alert,
  },
  'geometry': {
    'type': 'Point',
    'coordinates': [18, 48, 10],
  },
};
String payload([List<Map<String, dynamic>>? features]) => jsonEncode({
  'type': 'FeatureCollection',
  'features': features ?? [feature()],
  'bbox': [18, 48, 10, 18, 48, 10],
});
AppDataProvider providerFor(http.Client client, {LocationService? location}) =>
    AppDataProvider(
      client: client,
      locationService: location,
      now: () => DateTime.utc(2026, 10, 19, 12),
    );

class FakeLocation extends LocationService {
  FakeLocation({this.failure = false});
  final bool failure;
  @override
  Future<LocationResult> currentLocation() async {
    if (failure) throw const LocationFailure('Permission denied');
    return const LocationResult(48.15, 17.11, city: 'Bratislava');
  }
}

void main() {
  test(
    'GeoJSON parses integer/decimal magnitudes, coordinates and null fields',
    () {
      final model = EarthquakeModel.fromJson(
        jsonDecode(
          payload([
            feature(),
            feature(mag: 4.7),
            feature(mag: null, alert: null),
          ]),
        ),
      );
      expect(model.features[0].properties.mag, 4.0);
      expect(model.features[1].properties.mag, 4.7);
      expect(model.features[2].properties.mag, isNull);
      expect(model.features[2].properties.alert, isNull);
      expect(model.features[0].coordinates, [18.0, 48.0, 10.0]);
      expect(
        () => EarthquakeModel.fromJson({'error': 'bad'}),
        throwsFormatException,
      );
    },
  );

  test('Initial request includes yesterday and all of today, no location parameters', () async {
    var requests = 0;
    final provider = providerFor(
      MockClient((request) async {
        requests++;
        final q = request.url.queryParameters;
        expect(request.url.host, 'earthquake.usgs.gov');
        expect(q['starttime'], '2026-10-18T00:00:00Z');
        expect(q['endtime'], '2026-10-19T23:59:59.999Z');
        expect(q['minmagnitude'], '4');
        expect(q['limit'], '500');
        expect(q['nodata'], '204');
        expect(q.containsKey('latitude'), isFalse);
        return http.Response(payload(), 200);
      }),
    );
    addTearDown(provider.dispose);
    await provider.init();
    await provider.init();
    expect(requests, 1);
    expect(provider.hasDataLoaded, isTrue);
    expect(provider.isLoading, isFalse);
    expect(provider.earthquakeModel!.features, hasLength(1));
  });

  test('Every sorting choice requests its API order', () async {
    final orders = <String>[];
    final provider = providerFor(
      MockClient((request) async {
        orders.add(request.url.queryParameters['orderby']!);
        return http.Response(payload(), 200);
      }),
    );
    addTearDown(provider.dispose);
    await provider.init();
    for (final order in AppDataProvider.orders.keys) {
      await provider.setOrder(order);
    }
    expect(orders.sublist(1), AppDataProvider.orders.keys.toList());
    await expectLater(provider.setOrder('wrong'), throwsArgumentError);
  });

  test(
    'Invalid date range cannot request data, equal dates are inclusive',
    () async {
      var calls = 0;
      final provider = providerFor(
        MockClient((_) async {
          calls++;
          return http.Response(payload([]), 200);
        }),
      );
      addTearDown(provider.dispose);
      await provider.init();
      provider.setStartTime('2026-10-19');
      provider.setEndTime('2026-10-18');
      await expectLater(provider.applyDates(), throwsArgumentError);
      expect(calls, 1);
      provider.setEndTime('2026-10-19');
      expect(await provider.applyDates(), isTrue);
      expect(calls, 2);
      expect(provider.earthquakeModel!.features, isEmpty);
      expect(() => provider.setStartTime('2026-02-30'), throwsFormatException);
      expect(() => provider.setEndTime('2026-10-20'), throwsArgumentError);
    },
  );

  test(
    'HTTP failures, invalid JSON and no-data responses resolve loading state',
    () async {
      final responses = [
        http.Response('server error', 503),
        http.Response('not json', 200),
        http.Response('', 204),
      ];
      final provider = providerFor(
        MockClient((_) async => responses.removeAt(0)),
      );
      addTearDown(provider.dispose);
      await provider.init();
      expect(provider.error, contains('503'));
      expect(provider.isLoading, isFalse);
      expect(await provider.getEarthquakeData(), isFalse);
      expect(provider.error, contains('unreadable'));
      expect(await provider.getEarthquakeData(), isTrue);
      expect(provider.error, isNull);
      expect(provider.earthquakeModel!.features, isEmpty);
    },
  );

  test('Older HTTP request cannot replace a newer sorting response', () async {
    final first = Completer<http.Response>();
    var count = 0;
    final provider = providerFor(
      MockClient(
        (_) async => ++count == 1
            ? first.future
            : http.Response(payload([feature(id: 'new')]), 200),
      ),
    );
    addTearDown(provider.dispose);
    final initial = provider.init();
    await provider.setOrder('magnitude');
    first.complete(http.Response(payload([feature(id: 'old')]), 200));
    await initial;
    expect(provider.earthquakeModel!.features.single.id, 'new');
  });

  test('Location filter uses 300 km and disabling it removes geographic parameters', () async {
    final queries = <Map<String, String>>[];
    final provider = providerFor(
      MockClient((request) async {
        queries.add(request.url.queryParameters);
        return http.Response(payload(), 200);
      }),
      location: FakeLocation(),
    );
    addTearDown(provider.dispose);
    await provider.init();
    expect(await provider.setUseLocation(true), isNull);
    expect(provider.currentCity, 'Bratislava');
    expect(queries.last['latitude'], '48.15');
    expect(queries.last['maxradiuskm'], '300.0');
    await provider.setUseLocation(false);
    expect(queries.last.containsKey('latitude'), isFalse);
    expect(() => provider.setMaxRadiusKm(21000), throwsArgumentError);
  });

  test('Denied location keeps worldwide data available', () async {
    final provider = providerFor(
      MockClient((_) async => http.Response(payload(), 200)),
      location: FakeLocation(failure: true),
    );
    addTearDown(provider.dispose);
    await provider.init();
    expect(await provider.setUseLocation(true), 'Permission denied');
    expect(provider.shouldUseLocation, isFalse);
    expect(provider.hasDataLoaded, isTrue);
    expect(provider.isLocating, isFalse);
  });

  testWidgets(
    'List, sorting dialog, Settings navigation and date picker work',
    (tester) async {
      final provider = providerFor(
        MockClient((_) async => http.Response(payload(), 200)),
      );
      await tester.pumpWidget(
        ChangeNotifierProvider.value(value: provider, child: const MyApp()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Test region'), findsOneWidget);
      expect(find.text('M 4.0'), findsOneWidget);
      await tester.tap(find.byTooltip('Sort'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Magnitude — highest first'));
      await tester.pumpAndSettle();
      expect(provider.orderBy, 'magnitude');
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Time Settings'), findsOneWidget);
      await tester.tap(find.byTooltip('Select start date'));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      await tester.tap(find.text('17'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Test region'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      provider.dispose();
    },
  );

  testWidgets(
    'Small display shows empty and network-error states without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var fail = false;
      final provider = providerFor(
        MockClient(
          (_) async => fail
              ? http.Response('unavailable', 500)
              : http.Response(payload([]), 200),
        ),
      );
      await tester.pumpWidget(
        ChangeNotifierProvider.value(value: provider, child: const MyApp()),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('No records found'), findsOneWidget);
      fail = true;
      await provider.getEarthquakeData();
      await tester.pumpAndSettle();
      expect(find.text('Try again'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      provider.dispose();
    },
  );
}
