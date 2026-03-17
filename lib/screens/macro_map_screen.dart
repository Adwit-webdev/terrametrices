import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../utils/constants.dart';
import 'package:latlong2/latlong.dart';

class MacroMapScreen extends StatefulWidget {
  const MacroMapScreen({super.key});

  @override
  State<MacroMapScreen> createState() => _MacroMapScreenState();
}

class _MacroMapScreenState extends State<MacroMapScreen> {
  // These booleans control our dummy GEE layer toggles
  bool _showNDVI = false;
  bool _showLST = false;
  bool _showSuitability = false;

  // Centered on Roorkee, zoomed out a bit more for a "Macro" view
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phase A: Geospatial Sprawl'),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // A Stack allows us to float the control panel over the map
      body: Stack(
        children: [
          // 1. The Base OpenStreetMap
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
              // 1. The Standard Route (High Damage)
              Polyline(
                points: [
                  LatLng(AppConstants.roorkeeCenter.latitude, AppConstants.roorkeeCenter.longitude),
                  LatLng(AppConstants.roorkeeCenter.latitude + 0.01, AppConstants.roorkeeCenter.longitude + 0.01),
                ],
                color: Colors.red.withOpacity(0.5),
                strokeWidth: 4,
              ),
              // 2. The TerraMetrics Eco-Route (Low Damage)
              Polyline(
                points: [
                   LatLng(AppConstants.roorkeeCenter.latitude, AppConstants.roorkeeCenter.longitude),
                   LatLng(AppConstants.roorkeeCenter.latitude + 0.005, AppConstants.roorkeeCenter.longitude + 0.015),
                   LatLng(AppConstants.roorkeeCenter.latitude + 0.01, AppConstants.roorkeeCenter.longitude + 0.01),
                ],
                color: Colors.greenAccent,
                strokeWidth: 6,
              ),
            ],
          ),
            ],
          ),
          
          // 2. The Dummy GEE Overlays (Just colored containers for now)
          if (_showNDVI) 
            IgnorePointer(child: Container(color: Colors.green.withValues(alpha: 0.3))),
          if (_showLST) 
            IgnorePointer(child: Container(color: Colors.red.withValues(alpha: 0.3))),
          if (_showSuitability) 
            IgnorePointer(child: Container(color: Colors.blue.withValues(alpha: 0.3))),

          // 3. The Floating Control Panel
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Google Earth Engine Overlays',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildSwitch('NDVI (Vegetation Loss)', _showNDVI, Colors.greenAccent, (val) => setState(() => _showNDVI = val)),
                  _buildSwitch('LST (Surface Urban Heat)', _showLST, Colors.redAccent, (val) => setState(() => _showLST = val)),
                  _buildSwitch('Land Suitability (Safe Zones)', _showSuitability, Colors.lightBlueAccent, (val) => setState(() => _showSuitability = val)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // Helper widget to keep the switch code clean
  Widget _buildSwitch(String title, bool value, Color activeColor, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      value: value,
      activeThumbColor: activeColor,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}