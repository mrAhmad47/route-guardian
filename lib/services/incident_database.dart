import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/incident_report.dart';

class IncidentDatabase {
  static final IncidentDatabase instance = IncidentDatabase._init();
  static Database? _database;

  IncidentDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('incidents.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE incidents (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        locationName TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        description TEXT NOT NULL,
        severity INTEGER NOT NULL,
        source TEXT NOT NULL,
        verified INTEGER NOT NULL
      )
    ''');
  }

  // Insert a new incident report
  Future<void> insertIncident(IncidentReport report) async {
    final db = await database;
    await db.insert(
      'incidents',
      report.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all incidents (optionally filtered by recency)
  Future<List<IncidentReport>> getIncidents({int? daysBack}) async {
    final db = await database;
    
    String? whereClause;
    List<dynamic>? whereArgs;
    
    if (daysBack != null) {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysBack));
      whereClause = 'timestamp >= ?';
      whereArgs = [cutoffDate.toIso8601String()];
    }

    final maps = await db.query(
      'incidents',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'timestamp DESC',
    );

    return maps.map((map) => IncidentReport.fromMap(map)).toList();
  }

  // Get incidents near a location (within radius in kilometers)
  Future<List<IncidentReport>> getIncidentsNear({
    required double latitude,
    required double longitude,
    required double radiusKm,
    int? daysBack,
  }) async {
    final allIncidents = await getIncidents(daysBack: daysBack);
    
    // Simple distance filtering (for production, use geohash or spatial index)
    return allIncidents.where((incident) {
      final distance = _calculateDistance(
        latitude,
        longitude,
        incident.location.latitude,
        incident.location.longitude,
      );
      return distance <= radiusKm;
    }).toList();
  }

  // Simple haversine distance calculation (km)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371; // Earth radius in km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = 0.5 - 0.5 * (1 - 2 * (0.5 - 0.5 * (1 - dLat * dLat / 6))) +
        (1 - lat1 * lat1 / 90 / 90) * (1 - lat2 * lat2 / 90 / 90) * 
        (0.5 - 0.5 * (1 - dLon * dLon / 6));
    
    return 2 * R * (a < 1 ? (a > 0 ? 1 - 2 * a : 0) : 0);
  }

  double _toRadians(double degrees) => degrees * 3.14159265359 / 180;

  // Delete old incidents (cleanup task)
  Future<void> deleteOldIncidents({required int daysOld}) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
    
    await db.delete(
      'incidents',
      where: 'timestamp < ?',
      whereArgs: [cutoffDate.toIso8601String()],
    );
  }

  // Clear all incidents (for testing)
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('incidents');
  }

  // Close database
  Future close() async {
    final db = await database;
    await db.close();
  }
}
