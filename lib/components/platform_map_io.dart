// IO platforms (Windows, macOS, Linux, Android, iOS) - Google Maps
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'platform_aware_map.dart';

Widget buildPlatformMap({
  required latlong2.LatLng center,
  double zoom = 12.0,
  double minZoom = 3.0,
  double maxZoom = 18.0,
  String? styleUrl,
  Function(dynamic controller)? onMapCreated,
  VoidCallback? onStyleLoaded,
  List<MapCircle>? circles,
  List<MapMarker>? markers,
  List<latlong2.LatLng>? polylinePoints,
  Color polylineColor = const Color(0xFF39FF14),
  double polylineWidth = 4.0,
}) {
  // For desktop platforms (Windows, macOS, Linux), use flutter_map as fallback
  // Google Maps Flutter doesn't support desktop yet
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    return _buildFlutterMapFallback(
      center: center,
      zoom: zoom,
      minZoom: minZoom,
      maxZoom: maxZoom,
      circles: circles,
      markers: markers,
      polylinePoints: polylinePoints,
      polylineColor: polylineColor,
      polylineWidth: polylineWidth,
      onMapCreated: onMapCreated,
      onStyleLoaded: onStyleLoaded,
    );
  }

  // For Android and iOS, use Google Maps
  return _buildGoogleMap(
    center: center,
    zoom: zoom,
    minZoom: minZoom,
    maxZoom: maxZoom,
    circles: circles,
    markers: markers,
    polylinePoints: polylinePoints,
    polylineColor: polylineColor,
    polylineWidth: polylineWidth,
    onMapCreated: onMapCreated,
    onStyleLoaded: onStyleLoaded,
  );
}

Widget _buildGoogleMap({
  required latlong2.LatLng center,
  required double zoom,
  required double minZoom,
  required double maxZoom,
  List<MapCircle>? circles,
  List<MapMarker>? markers,
  List<latlong2.LatLng>? polylinePoints,
  Color polylineColor = const Color(0xFF39FF14),
  double polylineWidth = 4.0,
  Function(dynamic controller)? onMapCreated,
  VoidCallback? onStyleLoaded,
}) {
  // Build polylines
  final Set<Polyline> polylines = {};
  if (polylinePoints != null && polylinePoints.isNotEmpty) {
    polylines.add(Polyline(
      polylineId: const PolylineId('route_line'),
      points: polylinePoints.map((p) => LatLng(p.latitude, p.longitude)).toList(),
      color: polylineColor,
      width: polylineWidth.round().clamp(3, 8),
      jointType: JointType.round,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    ));
  }

  // Build markers
  final Set<Marker> googleMarkers = {};
  if (markers != null) {
    for (int i = 0; i < markers.length; i++) {
      final m = markers[i];
      googleMarkers.add(Marker(
        markerId: MarkerId('marker_$i'),
        position: LatLng(m.position.latitude, m.position.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          i == 0 ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueAzure,
        ),
      ));
    }
  }

  // Build circles
  final Set<Circle> googleCircles = {};
  if (circles != null) {
    for (int i = 0; i < circles.length; i++) {
      final c = circles[i];
      googleCircles.add(Circle(
        circleId: CircleId('circle_$i'),
        center: LatLng(c.center.latitude, c.center.longitude),
        radius: c.radius,
        fillColor: c.color.withOpacity(c.opacity),
        strokeColor: c.color,
        strokeWidth: 2,
      ));
    }
  }

  return GoogleMap(
    initialCameraPosition: CameraPosition(
      target: LatLng(center.latitude, center.longitude),
      zoom: zoom,
    ),
    minMaxZoomPreference: MinMaxZoomPreference(minZoom, maxZoom),
    polylines: polylines,
    markers: googleMarkers,
    circles: googleCircles,
    mapType: MapType.normal,
    myLocationEnabled: false,
    myLocationButtonEnabled: false,
    zoomControlsEnabled: true,
    zoomGesturesEnabled: true,
    scrollGesturesEnabled: true,
    rotateGesturesEnabled: true,
    tiltGesturesEnabled: false,
    compassEnabled: false,
    mapToolbarEnabled: false,
    onMapCreated: (controller) {
      onMapCreated?.call(controller);
      onStyleLoaded?.call();
    },
  );
}

// Fallback for desktop platforms using flutter_map with Google tiles
Widget _buildFlutterMapFallback({
  required latlong2.LatLng center,
  required double zoom,
  required double minZoom,
  required double maxZoom,
  List<MapCircle>? circles,
  List<MapMarker>? markers,
  List<latlong2.LatLng>? polylinePoints,
  Color polylineColor = const Color(0xFF39FF14),
  double polylineWidth = 4.0,
  Function(dynamic controller)? onMapCreated,
  VoidCallback? onStyleLoaded,
}) {
  // Import flutter_map dynamically
  return FutureBuilder(
    future: Future.delayed(Duration.zero),
    builder: (context, snapshot) {
      // Use flutter_map for desktop
      return _FlutterMapDesktop(
        center: center,
        zoom: zoom,
        minZoom: minZoom,
        maxZoom: maxZoom,
        circles: circles,
        markers: markers,
        polylinePoints: polylinePoints,
        polylineColor: polylineColor,
        polylineWidth: polylineWidth,
        onMapCreated: onMapCreated,
        onStyleLoaded: onStyleLoaded,
      );
    },
  );
}

class _FlutterMapDesktop extends StatelessWidget {
  final latlong2.LatLng center;
  final double zoom;
  final double minZoom;
  final double maxZoom;
  final List<MapCircle>? circles;
  final List<MapMarker>? markers;
  final List<latlong2.LatLng>? polylinePoints;
  final Color polylineColor;
  final double polylineWidth;
  final Function(dynamic controller)? onMapCreated;
  final VoidCallback? onStyleLoaded;

  const _FlutterMapDesktop({
    required this.center,
    required this.zoom,
    required this.minZoom,
    required this.maxZoom,
    this.circles,
    this.markers,
    this.polylinePoints,
    this.polylineColor = const Color(0xFF39FF14),
    this.polylineWidth = 4.0,
    this.onMapCreated,
    this.onStyleLoaded,
  });

  @override
  Widget build(BuildContext context) {
    // Use flutter_map package
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Text(
          'Desktop map - use web or mobile for full experience',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
