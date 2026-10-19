import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/earthquake_model.dart';
import '../services/location_service.dart';

class AppDataProvider extends ChangeNotifier {
  AppDataProvider({
    http.Client? client,
    LocationService? locationService,
    DateTime Function()? now,
  }) : _client = client ?? http.Client(),
       _locationService = locationService ?? LocationService(),
       _now = now ?? DateTime.now;

  final http.Client _client;
  final LocationService _locationService;
  final DateTime Function() _now;
  static final Uri _baseUrl = Uri.parse(
    'https://earthquake.usgs.gov/fdsnws/event/1/query',
  );
  static const orders = {
    'time': 'Time — newest first',
    'time-asc': 'Time — oldest first',
    'magnitude': 'Magnitude — highest first',
    'magnitude-asc': 'Magnitude — lowest first',
  };

  String _startTime = '';
  String _endTime = '';
  String _orderBy = 'time';
  double _maxRadiusKm = 300;
  double _latitude = 0;
  double _longitude = 0;
  String? _currentCity;
  bool _shouldUseLocation = false;
  bool _loading = false;
  bool _locating = false;
  bool _initialized = false;
  bool _disposed = false;
  int _requestId = 0;
  String? _error;
  EarthquakeModel? _earthquakeModel;
  String _appliedRange = 'Yesterday and today';

  String get startTime => _startTime;
  String get endTime => _endTime;
  String get orderBy => _orderBy;
  double get maxRadiusKm => _maxRadiusKm;
  double get maxRadiusThreshold => 20001.6;
  double get latitude => _latitude;
  double get longitude => _longitude;
  String? get currentCity => _currentCity;
  bool get shouldUseLocation => _shouldUseLocation;
  bool get isLoading => _loading;
  bool get isLocating => _locating;
  bool get hasDataLoaded => _earthquakeModel != null;
  String? get error => _error;
  EarthquakeModel? get earthquakeModel => _earthquakeModel;
  String get appliedRange => _appliedRange;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    final today = _now().toUtc();
    final day = DateTime.utc(today.year, today.month, today.day);
    _startTime = DateFormat('yyyy-MM-dd')
        .format(day.subtract(const Duration(days: 1)));
    _endTime = DateFormat('yyyy-MM-dd').format(day);
    await getEarthquakeData();
  }

  Map<String, String> get queryParams {
    final end = DateTime.parse('${_endTime}T00:00:00Z')
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));
    return Map.unmodifiable({
      'format': 'geojson',
      'starttime': '${_startTime}T00:00:00Z',
      // Include the whole selected end date, rather than midnight at its start.
      'endtime': end.toIso8601String(),
      'minmagnitude': '4',
      'orderby': _orderBy,
      'limit': '500',
      'eventtype': 'earthquake',
      'nodata': '204',
      if (_shouldUseLocation) ...{
        'latitude': '$_latitude',
        'longitude': '$_longitude',
        'maxradiuskm': '$_maxRadiusKm',
      },
    });
  }

  Future<bool> getEarthquakeData() async {
    final request = ++_requestId;
    _loading = true;
    _error = null;
    _earthquakeModel = null;
    _emit();
    try {
      if (DateTime.parse(_startTime).isAfter(DateTime.parse(_endTime))) {
        throw StateError(
          'Start date must be on or before the end date. Open Settings to correct it.',
        );
      }
      _appliedRange = '$_startTime → $_endTime';
      final response = await _client
          .get(_baseUrl.replace(queryParameters: queryParams))
          .timeout(const Duration(seconds: 25));
      if (_disposed || request != _requestId) return false;
      if (response.statusCode == 204) {
        _earthquakeModel = const EarthquakeModel(
          type: 'FeatureCollection',
          features: [],
        );
      } else if (response.statusCode == 200) {
        _earthquakeModel = EarthquakeModel.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
        );
      } else {
        throw StateError(
          'USGS returned HTTP ${response.statusCode}. Try a shorter date range.',
        );
      }
      return true;
    } on TimeoutException {
      if (request == _requestId) {
        _error = 'The request timed out. Check your connection and try again.';
      }
    } on FormatException {
      if (request == _requestId) {
        _error = 'USGS returned an unreadable response. Please try again.';
      }
    } catch (error) {
      if (request == _requestId) {
        _error = error is StateError ? error.message : 'Unable to reach USGS. Check your internet connection and try again.';
      }
    } finally {
      if (!_disposed && request == _requestId) {
        _loading = false;
        _emit();
      }
    }
    return false;
  }

  Future<void> setOrder(String value) async {
    if (!orders.containsKey(value)) throw ArgumentError.value(value);
    _orderBy = value;
    await getEarthquakeData();
  }

  void setStartTime(String value) {
    _checkDate(value);
    _startTime = value;
    _emit();
  }

  void setEndTime(String value) {
    _checkDate(value);
    _endTime = value;
    _emit();
  }

  void _checkDate(String value) {
    final date = DateFormat('yyyy-MM-dd').parseStrict(value, true);
    if (date.isBefore(DateTime.utc(2000)) || date.isAfter(_now().toUtc())) {
      throw ArgumentError('Select a date between 2000 and today.');
    }
  }

  Future<bool> applyDates() async {
    if (DateTime.parse(_startTime).isAfter(DateTime.parse(_endTime))) {
      throw ArgumentError('Start date must be on or before the end date.');
    }
    return getEarthquakeData();
  }

  Future<String?> setUseLocation(bool value) async {
    if (_locating) return null;
    if (!value) {
      _shouldUseLocation = false;
      await getEarthquakeData();
      return null;
    }
    _locating = true;
    _emit();
    try {
      final location = await _locationService.currentLocation();
      if (_disposed) return null;
      _latitude = location.latitude;
      _longitude = location.longitude;
      _currentCity = location.city;
      _shouldUseLocation = true;
      await getEarthquakeData();
      return null;
    } on LocationFailure catch (error) {
      return error.message;
    } catch (_) {
      return 'Could not get your location. Check GPS and permissions, then try again.';
    } finally {
      _locating = false;
      _emit();
    }
  }

  void setMaxRadiusKm(double value) {
    if (!value.isFinite || value <= 0 || value > maxRadiusThreshold) {
      throw ArgumentError.value(value);
    }
    _maxRadiusKm = value;
    _emit();
  }

  Color getAlertColor(String alert) => switch (alert) {
    'green' => Colors.green,
    'yellow' => Colors.yellow,
    'orange' => Colors.orange,
    'red' => Colors.red,
    _ => Colors.grey,
  };

  void _emit() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _requestId++;
    _client.close();
    super.dispose();
  }
}
