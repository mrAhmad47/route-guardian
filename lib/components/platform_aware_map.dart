import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlong2;

// Conditional imports based on platform
import 'platform_map_stub.dart'
    if (dart.library.io) 'platform_map_io.dart'
    if (dart.library.html) 'platform_map_web.dart';

/// A platform-aware map widget that uses:
/// - MapLibre GL on Android, iOS, and Web
/// - flutter_map on Windows, macOS, and Linux
class PlatformAwareMap extends StatelessWidget {
  final latlong2.LatLng center;
  final double zoom;
  final double minZoom;
  final double maxZoom;
  final String? styleUrl;
  final Function(dynamic controller)? onMapCreated;
  final VoidCallback? onStyleLoaded;
  final List<MapCircle>? circles;
  final List<MapMarker>? markers;
  final List<latlong2.LatLng>? polylinePoints;
  final Color polylineColor;
  final double polylineWidth;
  final Function(latlong2.LatLng)? onTap;
  final Function(latlong2.LatLng)? onCameraMove;
  final VoidCallback? onCameraIdle;

  const PlatformAwareMap({
    Key? key,
    required this.center,
    this.zoom = 12.0,
    this.minZoom = 3.0,
    this.maxZoom = 18.0,
    this.styleUrl,
    this.onMapCreated,
    this.onStyleLoaded,
    this.circles,
    this.markers,
    this.polylinePoints,
    this.polylineColor = const Color(0xFF39FF14),
    this.polylineWidth = 4.0,
    this.onTap,
    this.onCameraMove,
    this.onCameraIdle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildPlatformMap(
      center: center,
      zoom: zoom,
      minZoom: minZoom,
      maxZoom: maxZoom,
      styleUrl: styleUrl,
      onMapCreated: onMapCreated,
      onStyleLoaded: onStyleLoaded,
      circles: circles,
      markers: markers,
      polylinePoints: polylinePoints,
      polylineColor: polylineColor,
      polylineWidth: polylineWidth,
      onTap: onTap,
      onCameraMove: onCameraMove,
      onCameraIdle: onCameraIdle,
    );
  }
}

/// Circle data for heatmap visualization
class MapCircle {
  final latlong2.LatLng center;
  final double radius;
  final Color color;
  final double opacity;

  const MapCircle({
    required this.center,
    required this.radius,
    required this.color,
    this.opacity = 0.5,
  });
}

/// Marker data for points of interest
class MapMarker {
  final latlong2.LatLng position;
  final Widget? child;
  final double width;
  final double height;

  const MapMarker({
    required this.position,
    this.child,
    this.width = 40,
    this.height = 40,
  });
}
