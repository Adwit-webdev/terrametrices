import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/geo_point.dart';

class GeoApiService {
  static const String _baseUrl = 'https://terrametrics-api.onrender.com';

  Future<List<HeatmapPoint>> fetchPotholeHeatmap() async {
    final response = await _get('/api/v1/telemetry/pothole-heatmap');
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final features = decoded['features'] as List<dynamic>;
    return features
        .map((feature) => HeatmapPoint.fromGeoJson(feature as Map<String, dynamic>))
        .toList();
  }

  Future<GeoPoint> fetchLiveVehicle() async {
    final response = await _get('/api/v1/telemetry/live-vehicle');
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return GeoPoint.fromBackend(decoded);
  }

  Future<GeoLayerResult> fetchMapLayer({
    required double latitude,
    required double longitude,
    required int year,
  }) {
    return _postGeoLayer(
      path: '/api/v1/geo/map-layer?year=$year',
      title: 'Map Layer',
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<GeoLayerResult> fetchLandcover({
    required double latitude,
    required double longitude,
    required int year,
  }) {
    return _postGeoLayer(
      path: '/api/v1/geo/landcover/$year',
      title: 'Landcover / NDVI proxy',
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<GeoLayerResult> fetchUrbanGrowth({
    required double latitude,
    required double longitude,
    required int pastYear,
    required int currentYear,
  }) {
    return _postGeoLayer(
      path: '/api/v1/geo/urban-growth?past_year=$pastYear&current_year=$currentYear',
      title: 'Urban Growth',
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<GeoLayerResult> fetchUrbanPrediction({
    required double latitude,
    required double longitude,
    required int targetYear,
  }) {
    return _postGeoLayer(
      path: '/api/v1/geo/predict-urban-expansion?target_year=$targetYear',
      title: 'Urban Prediction / Suitability proxy',
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<EconomicsResult> fetchInfrastructureDepreciation({
    required double urbanGrowthRate,
    required double forestLossSqKm,
    required int roadDamageCount,
  }) async {
    final response = await _post(
      '/api/v1/eco/infrastructure-depreciation',
      body: {
        'urban_growth_rate': urbanGrowthRate,
        'forest_loss_sq_km': forestLossSqKm,
        'road_damage_count': roadDamageCount,
      },
    );

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return EconomicsResult.fromJson(decoded);
  }

  Future<String> submitManualReport({
    required double latitude,
    required double longitude,
    required double severityScore,
    required String notes,
  }) async {
    final response = await _post(
      '/api/v1/telemetry/manual-report',
      body: {
        'lat': latitude,
        'lon': longitude,
        'severity_score': severityScore,
        'notes': notes,
      },
    );

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return decoded['message']?.toString() ?? 'Manual hazard logged successfully.';
  }

  Future<GeoLayerResult> _postGeoLayer({
    required String path,
    required String title,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _post(
        path,
        body: {
          'lat': latitude,
          'lon': longitude,
        },
      );

      return GeoLayerResult(
        title: title,
        isAvailable: true,
        message: 'Live backend layer available.',
        payloadPreview: _trimPreview(response.body),
      );
    } catch (e) {
      return GeoLayerResult(
        title: title,
        isAvailable: false,
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<http.Response> _get(String path) async {
    final response = await http
        .get(Uri.parse('$_baseUrl$path'))
        .timeout(const Duration(seconds: 15));
    return _validateResponse(response);
  }

  Future<http.Response> _post(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl$path'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
    return _validateResponse(response);
  }

  http.Response _validateResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }

    String message = 'Request failed with status ${response.statusCode}.';
    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      if (decoded['detail'] != null) {
        message = decoded['detail'].toString();
      }
    } catch (_) {
      if (response.body.isNotEmpty) {
        message = response.body;
      }
    }

    throw Exception(message);
  }

  String _trimPreview(String rawBody) {
    final singleLine = rawBody.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (singleLine.length <= 120) {
      return singleLine;
    }
    return '${singleLine.substring(0, 117)}...';
  }
}
