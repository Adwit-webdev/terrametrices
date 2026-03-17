import 'package:geolocator/geolocator.dart';

class VibrationEvent {
  final Position location;
  final double zAxisForce;
  final DateTime timestamp; 

  VibrationEvent({
    required this.location,
    required this.zAxisForce,
    required this.timestamp,
  });
}