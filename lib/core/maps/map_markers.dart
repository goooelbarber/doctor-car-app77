import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarkers {
  static Marker pin(
    String id,
    LatLng pos, {
    double hue = BitmapDescriptor.hueRed,
    String? title,
    String? snippet,
  }) {
    return Marker(
      markerId: MarkerId(id),
      position: pos,
      icon: BitmapDescriptor.defaultMarkerWithHue(hue),
      infoWindow: (title == null && snippet == null)
          ? InfoWindow.noText
          : InfoWindow(title: title, snippet: snippet),
    );
  }
}
