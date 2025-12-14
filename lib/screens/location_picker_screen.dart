import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme/theme.dart';
import '../components/platform_aware_map.dart';
import '../services/geolocation_service.dart';

/// A screen that allows users to select a location on the map
class LocationPickerScreen extends StatefulWidget {
  final latlong2.LatLng? initialLocation;
  
  const LocationPickerScreen({Key? key, this.initialLocation}) : super(key: key);

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late latlong2.LatLng _selectedLocation;
  late latlong2.LatLng _currentMapCenter;
  String _locationText = 'Move map to select location';
  bool _isLoadingAddress = false;
  final GeolocationService _geoService = GeolocationService();
  GoogleMapController? _mapController;  // Store controller

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation ?? GeolocationService.defaultLocation;
    _currentMapCenter = _selectedLocation;
    _updateAddress();
  }

  void _updateAddress() async {
    setState(() => _isLoadingAddress = true);
    final address = await _geoService.getAddressFromCoordinates(_selectedLocation);
    if (mounted) {
      setState(() {
        _locationText = address;
        _isLoadingAddress = false;
      });
    }
  }

  void _onMapMoved(latlong2.LatLng newLocation) {
    // Update selected location silently (no rebuild)
    _selectedLocation = newLocation;
    _currentMapCenter = newLocation;
  }

  void _onMapIdle() {
    // Only update address when map stops
    if (mounted) {
      setState(() {});
      _updateAddress();
    }
  }

  Future<void> _useCurrentLocation() async {
    final location = await _geoService.getCurrentLocation();
    if (location != null) {
      setState(() {
        _selectedLocation = location;
        _currentMapCenter = location;
      });
      
      // Move map using controller instead of ValueKey
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(location.latitude, location.longitude),
            14.0,
          ),
        );
      }
      
      _updateAddress();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Using your current GPS location'),
            duration: Duration(seconds: 2),
            backgroundColor: AppTheme.neonGreen,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Could not get current location. Check permissions.'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          // Full Screen Map
          Positioned.fill(
            child: PlatformAwareMap(
              center: _currentMapCenter,
              zoom: 14.0,
              minZoom: 3.0,
              maxZoom: 18.0,
              onCameraMove: _onMapMoved,
              onCameraIdle: _onMapIdle,
              onMapCreated: (controller) {
                _mapController = controller as GoogleMapController?;
              },
            ),
          ),

          // Center Pin (always visible for selection)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_pin,
                  color: AppTheme.neonGreen,
                  size: 50,
                  shadows: [
                    Shadow(
                      color: AppTheme.neonGreen,
                      blurRadius: 10,
                    ),
                  ],
                ),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),

          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Select Location',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Card with confirm button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.backgroundDark,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Location info
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.neonGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: AppTheme.neonGreen,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selected Location',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            _isLoadingAddress
                                ? const SizedBox(
                                    height: 14,
                                    width: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(AppTheme.neonGreen),
                                    ),
                                  )
                                : Text(
                                    _locationText,
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Use Current Location Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _useCurrentLocation,
                      icon: const Icon(Icons.my_location),
                      label: const Text('Use Current Location'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.accentBlue,
                        side: const BorderSide(color: AppTheme.accentBlue),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Confirm Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Return selected location to the previous screen
                        Navigator.pop(context, _selectedLocation);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.neonGreen,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Confirm Location',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
