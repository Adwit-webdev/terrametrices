import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/geo_point.dart';
import '../services/geo_api_service.dart';
import '../services/telematics_service.dart';
import '../utils/constants.dart';

class MicroTelematicsScreen extends StatefulWidget {
  const MicroTelematicsScreen({super.key});

  @override
  State<MicroTelematicsScreen> createState() => _MicroTelematicsScreenState();
}

class _MicroTelematicsScreenState extends State<MicroTelematicsScreen> {
  final TelematicsService _telematicsService = TelematicsService();
  final GeoApiService _geoApiService = GeoApiService();

  late final VoidCallback _hazardListener;
  List<HeatmapPoint> _heatmapPoints = const [];
  GeoPoint? _liveVehicle;
  bool _isBackendLoading = true;
  String? _backendError;

  @override
  void initState() {
    super.initState();
    _hazardListener = () {
      if (mounted) {
        setState(() {});
      }
    };
    _telematicsService.addListener(_hazardListener);
    _telematicsService.startTracking();
    _loadBackendTelemetry();
  }

  @override
  void dispose() {
    _telematicsService.removeListener(_hazardListener);
    _telematicsService.stopTracking();
    super.dispose();
  }

  Future<void> _loadBackendTelemetry() async {
    setState(() {
      _isBackendLoading = true;
      _backendError = null;
    });

    try {
      final results = await Future.wait([
        _geoApiService.fetchPotholeHeatmap(),
        _geoApiService.fetchLiveVehicle(),
      ]);

      if (!mounted) {
        return;
      }

      setState(() {
        _heatmapPoints = results[0] as List<HeatmapPoint>;
        _liveVehicle = results[1] as GeoPoint;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _backendError = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isBackendLoading = false;
        });
      }
    }
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[
      ..._telematicsService.detectedHazards.map(
        (event) => Marker(
          point: LatLng(event.location.latitude, event.location.longitude),
          width: 42,
          height: 42,
          child: const Icon(
            Icons.warning_rounded,
            color: Colors.redAccent,
            size: 30,
          ),
        ),
      ),
    ];

    if (_liveVehicle != null) {
      markers.add(
        Marker(
          point: LatLng(_liveVehicle!.latitude, _liveVehicle!.longitude),
          width: 46,
          height: 46,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.lightBlueAccent,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 6),
              ],
            ),
            child: const Icon(Icons.directions_car, color: Colors.black),
          ),
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phase B: Live Road Health'),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBackendTelemetry,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: AppConstants.dehradunCenter,
              initialZoom: 13.5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.terrametrics',
              ),
              if (_heatmapPoints.isNotEmpty)
                CircleLayer(
                  circles: _heatmapPoints
                      .map(
                        (point) => CircleMarker(
                          point: LatLng(point.latitude, point.longitude),
                          radius: 8 + (point.severity * 10),
                          color: Color.lerp(
                                Colors.orangeAccent,
                                Colors.redAccent,
                                point.severity.clamp(0, 1),
                              )!
                              .withValues(alpha: 0.45),
                          borderColor: Colors.white70,
                          borderStrokeWidth: 1,
                        ),
                      )
                      .toList(),
                ),
              MarkerLayer(markers: _buildMarkers()),
            ],
          ),
          if (_isBackendLoading)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(minHeight: 3),
            ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _TelemetrySummaryCard(
              localHazardCount: _telematicsService.detectedHazards.length,
              heatmapCount: _heatmapPoints.length,
              backendError: _backendError,
              hasLiveVehicle: _liveVehicle != null,
            ),
          ),
        ],
      ),
    );
  }
}

class _TelemetrySummaryCard extends StatelessWidget {
  const _TelemetrySummaryCard({
    required this.localHazardCount,
    required this.heatmapCount,
    required this.backendError,
    required this.hasLiveVehicle,
  });

  final int localHazardCount;
  final int heatmapCount;
  final String? backendError;
  final bool hasLiveVehicle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Backend Telemetry',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Local hazards: $localHazardCount | Heatmap points: $heatmapCount | Live vehicle: ${hasLiveVehicle ? 'online' : 'offline'}',
            style: const TextStyle(color: Colors.white70),
          ),
          if (backendError != null) ...[
            const SizedBox(height: 8),
            Text(
              backendError!,
              style: const TextStyle(color: Colors.orangeAccent, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
