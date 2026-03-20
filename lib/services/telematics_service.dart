import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:terrametrics/models/vibration_event.dart';
import '../utils/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TelematicsService {
  Future<void> sendHazardToBackend(double lat, double lng, double force) async {
  final String apiUrl = 'https://terrametrics-api.onrender.com/api/v1/telemetry/sensor-data';

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'latitude': lat,
        'longitude': lng,
        'z_force': force,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ SUCCESS: Pothole data sent to Kanishk\'s Cloud!');
    } else {
      print('❌ Backend rejected the data: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Failed to connect to the cloud: $e');
  }
}
  // We use a StreamSubscription so we can turn the sensor on and off
  // to save battery when the user isn't driving.
  StreamSubscription<UserAccelerometerEvent>? _accelerometerSubscription;

  // The Z-axis is the up/down bounce of the phone.
  // We set a threshold. If the bounce is stronger than 5.0 m/s², it's a pothole.
  
  
  // A simple list to temporarily hold our detected road hazards
  List<VibrationEvent> detectedHazards = [];

  /// Starts listening to the phone's physical movements
  void startTracking() async {
    // --- NEW PERMISSION CHECK CODE ---
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("❌ GPS Permission Denied by User");
        return; // Stop the engine if they say no
      }
    }
    if (permission == LocationPermission.deniedForever) {
      print("❌ GPS Permission Permanently Denied");
      return; 
    }

    // 2. Start listening to the hardware accelerometer
  // Inside the accelerometer listener
_accelerometerSubscription = userAccelerometerEventStream().listen((event) async {
  if (event.z.abs() > AppConstants.bumpThreshold) {
    Position currentPosition = await Geolocator.getCurrentPosition();
    
    // CONVERSION: speed is in m/s. 4.16 m/s is roughly 15 km/h.
    if (currentPosition.speed > 4.16) { 
      detectedHazards.add(VibrationEvent(
        location: currentPosition,
        zAxisForce: event.z,
        timestamp: DateTime.now(),
      ));
      await sendHazardToBackend(currentPosition.latitude, currentPosition.longitude, event.z);
      print("🚗 Vehicle Hazard Detected at ${currentPosition.speed} m/s");
    } else {
      print("🚶 Ignoring vibration: User speed too low (${currentPosition.speed} m/s)");
    }
  }
});
  }

  /// Stops tracking to save battery and memory
  void stopTracking() {
    _accelerometerSubscription?.cancel();
  }
}