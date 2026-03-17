import 'package:geolocator/geolocator.dart';

class VibrationEvent {
  final Position location;
  final double zAxisForce; // How severe the bump was
  final DateTime timestamp; // When it happened

  VibrationEvent({
    required this.location,
    required this.zAxisForce,
    required this.timestamp,
  });
}