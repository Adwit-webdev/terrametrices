import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/geo_point.dart';
import '../services/geo_api_service.dart';
import '../utils/constants.dart';

class MacroMapScreen extends StatefulWidget {
  const MacroMapScreen({super.key});

  @override
  State<MacroMapScreen> createState() => _MacroMapScreenState();
}

class _MacroMapScreenState extends State<MacroMapScreen> {
  final GeoApiService _geoApiService = GeoApiService();

  bool _showNdvi = false;
  bool _showLst = false;
  bool _showSuitability = false;
  bool _isLoading = true;

  GeoLayerResult? _landcoverResult;
  GeoLayerResult? _mapLayerResult;
  GeoLayerResult? _urbanGrowthResult;
  GeoLayerResult? _predictionResult;

  @override
  void initState() {
    super.initState();
    _loadGeoData();
  }

  Future<void> _loadGeoData() async {
    setState(() {
      _isLoading = true;
    });

    final center = AppConstants.roorkeeCenter;
    final results = await Future.wait([
      _geoApiService.fetchLandcover(
        latitude: center.latitude,
        longitude: center.longitude,
        year: 2024,
      ),
      _geoApiService.fetchMapLayer(
        latitude: center.latitude,
        longitude: center.longitude,
        year: 2024,
      ),
      _geoApiService.fetchUrbanGrowth(
        latitude: center.latitude,
        longitude: center.longitude,
        pastYear: 2020,
        currentYear: 2024,
      ),
      _geoApiService.fetchUrbanPrediction(
        latitude: center.latitude,
        longitude: center.longitude,
        targetYear: 2030,
      ),
    ]);

    if (!mounted) {
      return;
    }

    setState(() {
      _landcoverResult = results[0];
      _mapLayerResult = results[1];
      _urbanGrowthResult = results[2];
      _predictionResult = results[3];
      _isLoading = false;
    });
  }

  Color? _overlayColor(bool enabled, GeoLayerResult? result, Color baseColor) {
    if (!enabled || result == null || !result.isAvailable) {
      return null;
    }
    return baseColor.withValues(alpha: 0.28);
  }

  @override
  Widget build(BuildContext context) {
    final ndviOverlay = _overlayColor(_showNdvi, _landcoverResult, Colors.green);
    final lstOverlay = _overlayColor(_showLst, _mapLayerResult, Colors.red);
    final suitabilityOverlay =
        _overlayColor(_showSuitability, _predictionResult, Colors.blue);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phase A: Geospatial Sprawl'),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadGeoData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: AppConstants.roorkeeCenter,
              initialZoom: 12.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.terrametrics',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [
                      LatLng(
                        AppConstants.roorkeeCenter.latitude,
                        AppConstants.roorkeeCenter.longitude,
                      ),
                      LatLng(
                        AppConstants.roorkeeCenter.latitude + 0.01,
                        AppConstants.roorkeeCenter.longitude + 0.01,
                      ),
                    ],
                    color: Colors.red.withValues(alpha: 0.5),
                    strokeWidth: 4,
                  ),
                  Polyline(
                    points: [
                      LatLng(
                        AppConstants.roorkeeCenter.latitude,
                        AppConstants.roorkeeCenter.longitude,
                      ),
                      LatLng(
                        AppConstants.roorkeeCenter.latitude + 0.005,
                        AppConstants.roorkeeCenter.longitude + 0.015,
                      ),
                      LatLng(
                        AppConstants.roorkeeCenter.latitude + 0.01,
                        AppConstants.roorkeeCenter.longitude + 0.01,
                      ),
                    ],
                    color: Colors.greenAccent,
                    strokeWidth: 6,
                  ),
                ],
              ),
            ],
          ),
          if (ndviOverlay != null) IgnorePointer(child: Container(color: ndviOverlay)),
          if (lstOverlay != null) IgnorePointer(child: Container(color: lstOverlay)),
          if (suitabilityOverlay != null)
            IgnorePointer(child: Container(color: suitabilityOverlay)),
          if (_isLoading)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(minHeight: 3),
            ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _GeoStatusBanner(
              results: [
                _landcoverResult,
                _mapLayerResult,
                _urbanGrowthResult,
                _predictionResult,
              ].whereType<GeoLayerResult>().toList(),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Live Geo Backend Layers',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildSwitch(
                    'NDVI / Landcover',
                    _showNdvi,
                    Colors.greenAccent,
                    _landcoverResult,
                    (value) => setState(() => _showNdvi = value),
                  ),
                  _buildSwitch(
                    'LST / Map Layer',
                    _showLst,
                    Colors.redAccent,
                    _mapLayerResult,
                    (value) => setState(() => _showLst = value),
                  ),
                  _buildSwitch(
                    'Suitability / Prediction',
                    _showSuitability,
                    Colors.lightBlueAccent,
                    _predictionResult,
                    (value) => setState(() => _showSuitability = value),
                  ),
                  const SizedBox(height: 10),
                  _GeoResultTile(result: _urbanGrowthResult),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitch(
    String title,
    bool value,
    Color activeColor,
    GeoLayerResult? result,
    ValueChanged<bool> onChanged,
  ) {
    final enabled = result?.isAvailable ?? false;
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.grey, fontSize: 13),
      ),
      subtitle: Text(
        result?.message ?? 'Checking backend...',
        style: TextStyle(
          color: enabled ? Colors.white70 : Colors.orangeAccent,
          fontSize: 11,
        ),
      ),
      value: value,
      activeThumbColor: activeColor,
      onChanged: enabled ? onChanged : null,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}

class _GeoStatusBanner extends StatelessWidget {
  const _GeoStatusBanner({required this.results});

  final List<GeoLayerResult> results;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const SizedBox.shrink();
    }

    final unavailableCount = results.where((result) => !result.isAvailable).length;
    final message = unavailableCount == 0
        ? 'All geo routes responded successfully.'
        : '$unavailableCount geo route(s) are unavailable on the backend right now.';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unavailableCount == 0 ? Colors.green.shade700 : Colors.orange.shade700,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _GeoResultTile extends StatelessWidget {
  const _GeoResultTile({required this.result});

  final GeoLayerResult? result;

  @override
  Widget build(BuildContext context) {
    if (result == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: result!.isAvailable ? Colors.greenAccent : Colors.orangeAccent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result!.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            result!.message,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          if (result!.payloadPreview != null) ...[
            const SizedBox(height: 6),
            Text(
              result!.payloadPreview!,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}
