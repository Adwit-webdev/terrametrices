import 'package:latlong2/latlong.dart';

class AppConstants {
  // Phase A & B Map Centers
  static const LatLng roorkeeCenter = LatLng(29.8543, 77.8880);
  
  // You can add more cities later if you expand the project!
  static const LatLng dehradunCenter = LatLng(30.3165, 78.0322);

  // Telematics Hardware Limits
  static const double bumpThreshold = 5.0; // The Z-axis threshold for a pothole
}