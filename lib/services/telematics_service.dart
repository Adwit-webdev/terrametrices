import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:sensors_plus/sensors_plus.dart';
import 'package:terrametrics/models/vibration_event.dart';

import 'location_service.dart';
import '../utils/constants.dart';

class TelematicsService extends ChangeNotifier {
  StreamSubscription<UserAccelerometerEvent>? _accelerometerSubscription;
  final List<VibrationEvent> detectedHazards = [];
  final LocationService _locationService = LocationService();

  Future<void> sendHazardToBackend({
    required double lat,
    required double lon,
    required double accX,
    required double accY,
    required double accZ,
    required double speed,
  }) async {
    const String apiUrl =
        'https://terrametrics-api.onrender.com/api/v1/telemetry/sensor-data';

    try {
      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'lat': lat,
              'lon': lon,
              'acc_x': accX,
              'acc_y': accY,
              'acc_z': accZ,
              'speed': speed,
              'timestamp': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("SUCCESS: Pothole data sent to backend");
      } else {
        print("Backend rejected the data: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } on TimeoutException {
      print("Backend request timed out");
    } catch (e) {
      print("Failed to connect to the backend: $e");
    }
  }

  Future<void> startTracking() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("GPS permission denied by user");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("GPS permission permanently denied");
      return;
    }

    _accelerometerSubscription =
        userAccelerometerEventStream().listen((event) async {
      if (event.z.abs() <= AppConstants.bumpThreshold) {
        return;
      }

      final Position currentPosition = await _locationService.getCurrentPosition();

      if (currentPosition.speed <= 4.16) {
        print(
          "Ignoring vibration: user speed too low (${currentPosition.speed} m/s)",
        );
        return;
      }

      detectedHazards.add(
        VibrationEvent(
          location: currentPosition,
          zAxisForce: event.z,
          timestamp: DateTime.now(),
        ),
      );
      notifyListeners();

      await sendHazardToBackend(
        lat: currentPosition.latitude,
        lon: currentPosition.longitude,
        accX: event.x,
        accY: event.y,
        accZ: event.z,
        speed: currentPosition.speed,
      );
      print("Vehicle hazard detected at ${currentPosition.speed} m/s");
    });
  }

  void stopTracking() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
  }
}
