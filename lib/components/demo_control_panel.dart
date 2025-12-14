import 'package:flutter/material.dart';
import '../services/simulated_data_service.dart';
import '../services/incident_database.dart';
import '../theme/theme.dart';

class DemoControlPanel extends StatefulWidget {
  final VoidCallback? onDataUpdated;
  
  const DemoControlPanel({Key? key, this.onDataUpdated}) : super(key: key);

  @override
  State<DemoControlPanel> createState() => _DemoControlPanelState();
}

class _DemoControlPanelState extends State<DemoControlPanel> {
  final SimulatedDataService _simService = SimulatedDataService();
  final IncidentDatabase _db = IncidentDatabase.instance;
  
  bool _isSimulating = false;
  Map<String, dynamic> _stats = {};
  
  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _simService.getSimulationStats();
    setState(() {
      _stats = stats;
    });
  }

  Future<void> _toggleSimulation() async {
    if (_isSimulating) {
      _simService.stopSimulation();
      setState(() {
        _isSimulating = false;
      });
    } else {
      _simService.startSimulation(interval: const Duration(seconds: 30));
      setState(() {
        _isSimulating = true;
      });
      
      // Update stats periodically
      Future.doWhile(() async {
        if (!_isSimulating) return false;
        await Future.delayed(const Duration(seconds: 5));
        await _loadStats();
        widget.onDataUpdated?.call();
        return _isSimulating;
      });
    }
  }

  Future<void> _seedDatabase() async {
    await _simService.seedDatabase();
    await _loadStats();
    widget.onDataUpdated?.call();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Database seeded with 20 sample incidents'),
          backgroundColor: AppTheme.neonGreen,
        ),
      );
    }
  }

  Future<void> _clearDatabase() async {
    await _db.clearAll();
    await _loadStats();
    widget.onDataUpdated?.call();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Database cleared'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neonGreen.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.science, color: AppTheme.neonGreen, size: 20),
              const SizedBox(width: 8),
              const Text(
                'DEMO CONTROL PANEL',
                style: TextStyle(
                  color: AppTheme.neonGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Stats
          if (_stats.isNotEmpty) ...[
            _buildStatRow('Total Incidents', '${_stats['total'] ?? 0}'),
            _buildStatRow('Last 24h', '${_stats['last24h'] ?? 0}'),
            _buildStatRow('Verified', '${_stats['verified'] ?? 0}'),
            const SizedBox(height: 12),
          ],
          
          // Controls
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _toggleSimulation,
                  icon: Icon(_isSimulating ? Icons.stop : Icons.play_arrow),
                  label: Text(_isSimulating ? 'STOP DEMO' : 'START DEMO'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSimulating ? AppTheme.dangerRed : AppTheme.neonGreen,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _seedDatabase,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.accentBlue,
                    side: const BorderSide(color: AppTheme.accentBlue),
                  ),
                  child: const Text('SEED DATA'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearDatabase,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('CLEAR ALL'),
                ),
              ),
            ],
          ),
          
          if (_isSimulating) ...[
            const SizedBox(height: 12),
            Row(
              children: const [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.neonGreen,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Simulating real-time incidents...',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.neonGreen,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _simService.stopSimulation();
    super.dispose();
  }
}
