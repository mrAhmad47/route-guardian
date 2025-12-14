import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// N-ATLaS AI Service for incident analysis and news processing
/// 
/// This service communicates with the Python N-ATLaS server
/// for real AI-powered analysis.
class NAtlasService {
  static final NAtlasService instance = NAtlasService._init();
  
  // Server configuration - auto-detects platform
  static String get serverUrl => kIsWeb
      ? 'http://127.0.0.1:8765'  // Web: localhost
      : 'http://10.227.22.32:8765';  // Mobile: WiFi IP
  static const String modelPath = 'models/N-ATLaS.Q2_K.gguf';
  
  Process? _serverProcess;
  bool _isServerRunning = false;
  
  NAtlasService._init();

  /// Check if the N-ATLaS model file exists
  Future<bool> isModelAvailable() async {
    try {
      final file = File(modelPath);
      return await file.exists();
    } catch (e) {
      debugPrint('Error checking model: $e');
      return false;
    }
  }

  /// Start the Python inference server
  Future<bool> startServer() async {
    if (_isServerRunning) return true;
    
    try {
      debugPrint('Starting N-ATLaS server...');
      _serverProcess = await Process.start(
        'python',
        ['natlas_server.py', '8765'],
        workingDirectory: Directory.current.path,
      );
      
      // Wait for server to start
      await Future.delayed(const Duration(seconds: 3));
      
      // Check if server is running
      final status = await getServerStatus();
      _isServerRunning = status.isAvailable;
      
      debugPrint('Server started: $_isServerRunning');
      return _isServerRunning;
    } catch (e) {
      debugPrint('Error starting server: $e');
      return false;
    }
  }

  /// Stop the Python server
  void stopServer() {
    _serverProcess?.kill();
    _isServerRunning = false;
  }

  /// Get server status
  Future<ModelStatus> getServerStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$serverUrl/status'),
      ).timeout(const Duration(seconds: 2));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ModelStatus(
          isAvailable: true,
          isLoaded: data['model_loaded'] ?? false,
          message: data['model_loaded'] == true 
              ? 'N-ATLaS model loaded and ready' 
              : 'Server running, model not loaded',
        );
      }
    } catch (e) {
      debugPrint('Server not responding: $e');
    }
    
    return ModelStatus(
      isAvailable: false,
      isLoaded: false,
      message: 'N-ATLaS server not running. Start with: python natlas_server.py',
    );
  }

  /// Get model status information
  Future<ModelStatus> getModelStatus() async {
    final serverStatus = await getServerStatus();
    if (serverStatus.isAvailable) {
      return serverStatus;
    }
    
    // Check if model file exists
    final exists = await isModelAvailable();
    if (!exists) {
      return ModelStatus(
        isAvailable: false,
        isLoaded: false,
        message: 'Model not found. Please download N-ATLaS.Q2_K.gguf to the models/ folder.',
      );
    }
    
    return ModelStatus(
      isAvailable: true,
      isLoaded: false,
      message: 'Model available. Start server with: python natlas_server.py',
    );
  }

  /// Analyze text for potential safety incidents using the AI model
  Future<IncidentAnalysis> analyzeText(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['error'] != null) {
          return IncidentAnalysis.error(data['error']);
        }
        
        return IncidentAnalysis(
          hasIncident: data['has_incident'] ?? false,
          incidentType: data['type'] ?? 'Unknown',
          severity: (data['severity'] ?? 0.5).toDouble(),
          confidence: (data['confidence'] ?? 0.5).toDouble(),
          summary: data['summary'] ?? '',
          suggestedLocation: data['location'],
        );
      }
    } catch (e) {
      debugPrint('Analysis error: $e');
      // Fallback to simulated analysis
      return _simulatedAnalysis(text);
    }
    
    return _simulatedAnalysis(text);
  }

  /// Fallback simulated analysis when server is not available
  IncidentAnalysis _simulatedAnalysis(String text) {
    final lowerText = text.toLowerCase();
    
    // Detect incident keywords
    final incidentKeywords = {
      'robbery': ['robbery', 'robbed', 'stolen', 'thief', 'thieves', 'armed'],
      'accident': ['accident', 'crash', 'collision', 'injured', 'vehicle'],
      'harassment': ['harassment', 'harassed', 'threatened', 'intimidation'],
      'assault': ['assault', 'attacked', 'beaten', 'violence', 'fight'],
      'suspicious': ['suspicious', 'strange', 'unusual', 'watching'],
    };
    
    String? detectedType;
    double severity = 0.3;
    
    for (final entry in incidentKeywords.entries) {
      for (final keyword in entry.value) {
        if (lowerText.contains(keyword)) {
          detectedType = entry.key;
          severity = entry.key == 'robbery' || entry.key == 'assault' ? 0.8 : 0.5;
          break;
        }
      }
      if (detectedType != null) break;
    }
    
    return IncidentAnalysis(
      hasIncident: detectedType != null,
      incidentType: detectedType ?? 'None detected',
      severity: severity,
      confidence: 0.75,
      summary: detectedType != null 
          ? 'Detected potential ${detectedType} incident in the text.'
          : 'No safety incidents detected in the provided text.',
      suggestedLocation: null,
    );
  }

  /// Analyze a news article URL for safety incidents
  Future<IncidentAnalysis> analyzeNewsUrl(String url) async {
    // For demo, return analysis based on URL
    return IncidentAnalysis(
      hasIncident: true,
      incidentType: 'News Analysis',
      severity: 0.6,
      confidence: 0.85,
      summary: 'Article analysis from: $url - News content would be extracted and analyzed.',
      suggestedLocation: null,
    );
  }

  /// Assess the severity of an incident based on description
  Future<SeverityAssessment> assessSeverity(String description, String incidentType) async {
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/severity'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'description': description,
          'type': incidentType,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SeverityAssessment(
          severity: data['severity'] ?? 50,
          reasoning: data['reasoning'] ?? 'AI assessment',
        );
      }
    } catch (e) {
      debugPrint('Severity assessment error: $e');
    }
    
    // Fallback
    return _fallbackSeverityAssessment(incidentType);
  }

  SeverityAssessment _fallbackSeverityAssessment(String incidentType) {
    final severityMap = {
      'robbery': 80,
      'harassment': 60,
      'accident': 70,
      'vandalism': 40,
      'suspicious activity': 50,
    };
    
    return SeverityAssessment(
      severity: severityMap[incidentType.toLowerCase()] ?? 50,
      reasoning: 'Rule-based assessment',
    );
  }

  /// Cleanup resources
  void dispose() {
    stopServer();
  }
}

// === Data Models ===

class ModelStatus {
  final bool isAvailable;
  final bool isLoaded;
  final String message;

  ModelStatus({
    required this.isAvailable,
    required this.isLoaded,
    required this.message,
  });
}

class IncidentAnalysis {
  final bool hasIncident;
  final String incidentType;
  final double severity;
  final double confidence;
  final String summary;
  final String? suggestedLocation;
  final String? error;

  IncidentAnalysis({
    required this.hasIncident,
    required this.incidentType,
    required this.severity,
    required this.confidence,
    required this.summary,
    this.suggestedLocation,
    this.error,
  });

  factory IncidentAnalysis.notAvailable() {
    return IncidentAnalysis(
      hasIncident: false,
      incidentType: '',
      severity: 0,
      confidence: 0,
      summary: '',
      error: 'N-ATLaS model not available',
    );
  }

  factory IncidentAnalysis.error(String message) {
    return IncidentAnalysis(
      hasIncident: false,
      incidentType: '',
      severity: 0,
      confidence: 0,
      summary: '',
      error: message,
    );
  }

  bool get isSuccessful => error == null;
}

class SeverityAssessment {
  final int severity; // 0-100
  final String reasoning;

  SeverityAssessment({
    required this.severity,
    required this.reasoning,
  });
}

class VerificationResult {
  final bool isVerified;
  final double confidence;
  final String reason;

  VerificationResult({
    required this.isVerified,
    required this.confidence,
    required this.reason,
  });
}

class LocationExtraction {
  final String locationName;
  final double? latitude;
  final double? longitude;

  LocationExtraction({
    required this.locationName,
    this.latitude,
    this.longitude,
  });

  bool get hasCoordinates => latitude != null && longitude != null;
}
