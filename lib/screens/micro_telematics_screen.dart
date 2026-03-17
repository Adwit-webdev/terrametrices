import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/telematics_service.dart';
import '../utils/constants.dart';

class MicroTelematicsScreen extends StatefulWidget {
  const MicroTelematicsScreen({super.key}); // Fix 1 applied

  @override
  State<MicroTelematicsScreen> createState() => _MicroTelematicsScreenState(); // Fix 2 applied
}

class _MicroTelematicsScreenState extends State<MicroTelematicsScreen> {
  // 1. Initialize our hardware service
  final TelematicsService _telematicsService = TelematicsService();
  
  // 2. Center the map on IIT Roorkee / Uttarakhand initially
  

  @override
  void initState() {
    super.initState();
    _telematicsService.startTracking();
  }

  @override
  void dispose() {
    _telematicsService.stopTracking();
    super.dispose();
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
            onPressed: () {
              print("Manual Refresh: Found ${_telematicsService.detectedHazards.length} hazards"); // Debug log
              setState(() {}); 
            },
          )
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: AppConstants.roorkeeCenter, // Fix 3 applied!
          initialZoom: 14.0, 
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.terrametrics',
          ),
          MarkerLayer(
            // We renamed the variable to 'event' so it makes more sense
            markers: _telematicsService.detectedHazards.map((event) {
              return Marker(
                // Notice how we use event.location.latitude now!
                point: LatLng(event.location.latitude, event.location.longitude),
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.redAccent,
                  size: 30,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}