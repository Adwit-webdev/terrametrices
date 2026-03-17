import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:terrametrics/models/vibration_event.dart';
import '../utils/constants.dart';

class TelematicsService {
  // We use a StreamSubscription so we can turn the sensor on and off
  // to save battery when the user isn't driving.
  StreamSubscription<UserAccelerometerEvent>? _accelerometerSubscription;

  // The Z-axis is the up/down bounce of the phone.
  // We set a threshold. If the bounce is stronger than 5.0 m/s², it's a pothole.
  
  
  // A simple list to temporarily hold our detected road hazards
  List<VibrationEvent> detectedHazards = [];

  /// Starts listening to the phone's physical movements
  void startTracking() async {
    // 1. First, check if we have GPS permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return; // Exit if denied
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