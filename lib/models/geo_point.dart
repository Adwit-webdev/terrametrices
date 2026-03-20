class GeoPoint {
  const GeoPoint({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  factory GeoPoint.fromBackend(Map<String, dynamic> json) {
    return GeoPoint(
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lon'] as num).toDouble(),
    );
  }
}

class HeatmapPoint extends GeoPoint {
  const HeatmapPoint({
    required super.latitude,
    required super.longitude,
    required this.severity,
  });

  final double severity;

  factory HeatmapPoint.fromGeoJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List<dynamic>;
    final properties = json['properties'] as Map<String, dynamic>;

    return HeatmapPoint(
      latitude: (coordinates[1] as num).toDouble(),
      longitude: (coordinates[0] as num).toDouble(),
      severity: (properties['severity'] as num).toDouble(),
    );
  }
}

class GeoLayerResult {
  const GeoLayerResult({
    required this.title,
    required this.isAvailable,
    required this.message,
    this.payloadPreview,
  });

  final String title;
  final bool isAvailable;
  final String message;
  final String? payloadPreview;
}

class EconomicsResult {
  const EconomicsResult({
    required this.totalCostLabel,
    required this.rawCostInr,
    required this.breakdown,
  });

  final String totalCostLabel;
  final double rawCostInr;
  final Map<String, String> breakdown;

  factory EconomicsResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final breakdownJson = data['breakdown'] as Map<String, dynamic>;

    return EconomicsResult(
      totalCostLabel: data['formatted_total_cost'] as String,
      rawCostInr: (data['raw_cost_inr'] as num).toDouble(),
      breakdown: breakdownJson.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }
}
