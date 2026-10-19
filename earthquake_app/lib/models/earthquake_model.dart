class EarthquakeModel {
  const EarthquakeModel({
    required this.type,
    required this.features,
    this.bbox = const [],
  });
  final String type;
  final List<Features> features;
  final List<double> bbox;

  factory EarthquakeModel.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'FeatureCollection' || json['features'] is! List) {
      throw const FormatException('Invalid earthquake GeoJSON response');
    }
    return EarthquakeModel(
      type: json['type'] as String,
      features: List.unmodifiable(
        (json['features'] as List).map(
          (item) => Features.fromJson(item as Map<String, dynamic>),
        ),
      ),
      bbox: List.unmodifiable(
        (json['bbox'] as List? ?? []).map((value) => (value as num).toDouble()),
      ),
    );
  }
}

class Features {
  const Features({
    required this.id,
    required this.properties,
    this.coordinates = const [],
  });
  final String id;
  final Properties properties;
  // GeoJSON coordinates: longitude, latitude, depth (km).
  final List<double> coordinates;

  factory Features.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] as Map<String, dynamic>?;
    return Features(
      id: json['id'] as String? ?? '',
      properties: Properties.fromJson(
        json['properties'] as Map<String, dynamic>? ?? {},
      ),
      coordinates: List.unmodifiable(
        (geometry?['coordinates'] as List? ?? []).map(
          (value) => (value as num).toDouble(),
        ),
      ),
    );
  }
}

class Properties {
  const Properties({
    this.mag,
    this.place,
    this.time,
    this.updated,
    this.title,
    this.alert,
  });
  final double? mag;
  final String? place;
  final int? time;
  final int? updated;
  final String? title;
  final String? alert;

  factory Properties.fromJson(Map<String, dynamic> json) => Properties(
    mag: (json['mag'] as num?)?.toDouble(),
    place: json['place'] as String?,
    time: (json['time'] as num?)?.toInt(),
    updated: (json['updated'] as num?)?.toInt(),
    title: json['title'] as String?,
    alert: json['alert'] as String?,
  );
}
