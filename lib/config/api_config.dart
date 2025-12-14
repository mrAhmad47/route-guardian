/// API Configuration for RouteGuardian
/// 
/// Contains API keys and configuration for external services.
/// NOTE: In production, use environment variables or secure storage.
class ApiConfig {
  // Google Maps API Key
  static const String googleMapsApiKey = 'AIzaSyDLgxgrNJq-4xjRi_cc9RPvX-kKC06VwyQ';
  
  // N-ATLaS Server
  static const String natlasServerUrl = 'http://localhost:8765';
  
  // Google Maps URLs
  static String get googleMapsTileUrl => 
      'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}&key=$googleMapsApiKey';
  
  static String get googleMapsHybridUrl => 
      'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}&key=$googleMapsApiKey';
  
  static String get googleMapsSatelliteUrl => 
      'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}&key=$googleMapsApiKey';
  
  static String get googleMapsTerrainUrl => 
      'https://mt1.google.com/vt/lyrs=p&x={x}&y={y}&z={z}&key=$googleMapsApiKey';
  
  // Directions API
  static String getDirectionsUrl(String origin, String destination) =>
      'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$googleMapsApiKey';
  
  // Geocoding API
  static String getGeocodingUrl(String address) =>
      'https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=$googleMapsApiKey';
  
  // Reverse Geocoding
  static String getReverseGeocodingUrl(double lat, double lng) =>
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$googleMapsApiKey';
}
