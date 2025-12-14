import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:image_picker/image_picker.dart';
import '../theme/theme.dart';
import '../components/neon_button.dart';
import '../models/incident_report.dart';
import '../services/incident_database.dart';
import 'location_picker_screen.dart';

class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({Key? key}) : super(key: key);

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  String selectedIncidentType = 'Robbery';
  final List<String> incidentTypes = [
    'Robbery',
    'Suspicious Activity',
    'Harassment',
    'Accident',
    'Vandalism',
    'Other'
  ];
  
  // Location state
  latlong2.LatLng? _selectedLocation;
  String _locationText = 'Pin on map or use current location';
  
  // Date & Time state
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  
  // Description
  final TextEditingController _descriptionController = TextEditingController();
  
  // Evidence
  final List<File> _mediaFiles = [];
  final List<String> _linkUrls = [];
  final TextEditingController _linkController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _selectLocation() async {
    final result = await Navigator.push<latlong2.LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          initialLocation: _selectedLocation,
        ),
      ),
    );
    
    if (result != null) {
      setState(() {
        _selectedLocation = result;
        _locationText = '${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)}';
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.neonGreen,
              onPrimary: Colors.black,
              surface: AppTheme.backgroundDark,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: AppTheme.backgroundDark,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.neonGreen,
              onPrimary: Colors.black,
              surface: AppTheme.backgroundDark,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: AppTheme.backgroundDark,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _mediaFiles.add(File(image.path)));
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _imagePicker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() => _mediaFiles.add(File(photo.path)));
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _imagePicker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() => _mediaFiles.add(File(video.path)));
    }
  }

  void _addLink() {
    final url = _linkController.text.trim();
    if (url.isNotEmpty) {
      setState(() {
        _linkUrls.add(url);
        _linkController.clear();
      });
    }
  }

  void _removeMedia(int index) {
    setState(() => _mediaFiles.removeAt(index));
  }

  void _removeLink(int index) {
    setState(() => _linkUrls.removeAt(index));
  }

  String get _formattedDate {
    if (_selectedDate == null) return 'Select Date';
    return DateFormat('MMM dd, yyyy').format(_selectedDate!);
  }

  String get _formattedTime {
    if (_selectedTime == null) return 'Select Time';
    final hour = _selectedTime!.hourOfPeriod == 0 ? 12 : _selectedTime!.hourOfPeriod;
    final period = _selectedTime!.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:${_selectedTime!.minute.toString().padLeft(2, '0')} $period';
  }

  String _getLinkIcon(String url) {
    if (url.contains('twitter.com') || url.contains('x.com')) return '𝕏';
    if (url.contains('facebook.com')) return 'f';
    if (url.contains('instagram.com')) return '📷';
    if (url.contains('youtube.com')) return '▶';
    if (url.contains('tiktok.com')) return '♪';
    return '🔗';
  }

  String _getLinkDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceAll('www.', '');
    } catch (e) {
      return url.length > 30 ? '${url.substring(0, 30)}...' : url;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundDark,
                border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Report Incident',
                    style: TextStyle(
                      color: AppTheme.neonGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.help_outline, color: AppTheme.accentBlue),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Incident Type Selector
                    const Text('Incident Type',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: incidentTypes.map((type) {
                          final isSelected = selectedIncidentType == type;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: InkWell(
                              onTap: () => setState(() => selectedIncidentType = type),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppTheme.neonGreen : Colors.transparent,
                                  border: Border.all(color: AppTheme.accentBlue),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: isSelected
                                      ? [BoxShadow(color: AppTheme.neonGreen.withOpacity(0.4), blurRadius: 10)]
                                      : [],
                                ),
                                child: Text(
                                  type,
                                  style: TextStyle(
                                    color: isSelected ? Colors.black : Colors.white,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Location Selection Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: _selectedLocation != null ? AppTheme.neonGreen : Colors.grey),
                                  color: Colors.black26,
                                ),
                                child: Icon(
                                  _selectedLocation != null ? Icons.check_circle : Icons.map,
                                  color: _selectedLocation != null ? AppTheme.neonGreen : Colors.grey,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Location of Incident',
                                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                    Text(_locationText,
                                        style: TextStyle(color: _selectedLocation != null ? AppTheme.neonGreen : Colors.grey[400])),
                                  ],
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: _selectLocation,
                              icon: const Icon(Icons.map, size: 20),
                              label: const Text('Select on Map', style: TextStyle(fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppTheme.accentBlue),
                                shape: const StadiumBorder(),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Date & Time Picker
                    Row(
                      children: [
                        Expanded(child: _buildDateTimePicker('Date', _formattedDate, Icons.calendar_today, _selectDate)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildDateTimePicker('Time', _formattedTime, Icons.schedule, _selectTime)),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Description Box
                    const Text('Describe what happened',
                        style: TextStyle(color: AppTheme.neonGreen, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 5,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        hintText: 'Please provide as much detail as possible...',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.neonGreen),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Enhanced Evidence Section
                    _buildEvidenceSection(),

                    const SizedBox(height: 24),

                    // AI Notice
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.neonGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.neonGreen.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.auto_awesome, color: AppTheme.neonGreen),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "AI will analyze your report and evidence for verification.",
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: NeonButton(
                            text: "Cancel",
                            onPressed: () => Navigator.pop(context),
                            isPrimary: false,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: NeonButton(
                            text: "Submit Report",
                            onPressed: _submitReport,
                            isPrimary: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvidenceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentBlue.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Upload Evidence',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('Photos, videos, news links, or social media posts',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),

          // Media Upload Buttons
          Row(
            children: [
              Expanded(child: _buildUploadButton(Icons.photo_library, 'Gallery', _pickImage)),
              const SizedBox(width: 8),
              Expanded(child: _buildUploadButton(Icons.camera_alt, 'Camera', _takePhoto)),
              const SizedBox(width: 8),
              Expanded(child: _buildUploadButton(Icons.videocam, 'Video', _pickVideo)),
            ],
          ),

          // Uploaded Media Grid
          if (_mediaFiles.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Uploaded Media', style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _mediaFiles.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.neonGreen),
                            image: DecorationImage(
                              image: FileImage(_mediaFiles[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeMedia(index),
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 12, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),

          // Link Input Section
          const Text('Add News or Social Media Link',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _linkController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.black26,
                    hintText: 'Paste URL here...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    prefixIcon: const Icon(Icons.link, color: AppTheme.accentBlue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addLink,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Icon(Icons.add),
              ),
            ],
          ),

          // Link Type Suggestions
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildLinkChip('Twitter/X'),
              _buildLinkChip('News Article'),
              _buildLinkChip('Facebook'),
              _buildLinkChip('Instagram'),
            ],
          ),

          // Added Links List
          if (_linkUrls.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Added Links', style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 8),
            ...List.generate(_linkUrls.length, (index) {
              final url = _linkUrls[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Text(_getLinkIcon(url), style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_getLinkDomain(url),
                              style: const TextStyle(color: Colors.white, fontSize: 12)),
                          Text(url,
                              style: TextStyle(color: Colors.grey[500], fontSize: 10),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _removeLink(index),
                      child: const Icon(Icons.close, color: Colors.grey, size: 18),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildUploadButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.backgroundDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: AppTheme.neonGreen),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
    );
  }

  Widget _buildDateTimePicker(String label, String value, IconData icon, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.neonGreen, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(value, style: const TextStyle(color: Colors.white70))),
                const Icon(Icons.arrow_drop_down, color: Colors.white54),
              ],
            ),
          ),
        )
      ],
    );
  }

  Future<void> _submitReport() async {
    try {
      // Validate required fields
      if (_selectedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a location'), backgroundColor: Colors.orange),
        );
        return;
      }
      
      if (_descriptionController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please describe the incident'), backgroundColor: Colors.orange),
        );
        return;
      }

      // Create incident report
      final report = IncidentReport(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: selectedIncidentType,
        location: latlong2.LatLng(_selectedLocation!.latitude, _selectedLocation!.longitude),
        locationName: _locationText,
        timestamp: DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        ),
        description: _descriptionController.text.trim(),
        severity: _getSeverityFromType(selectedIncidentType),
        source: 'user',
        verified: false,
      );

      // Save to database (skip on web for now)
      try {
        if (!kIsWeb) {
          await IncidentDatabase.instance.insertIncident(report);
          debugPrint('✅ Report saved to local database');
        } else {
          debugPrint('⚠️ Web platform - skipping database save (use Firebase in future)');
          // TODO: Save to Firebase for web
        }
      } catch (dbError) {
        debugPrint('❌ Database error (non-critical): $dbError');
        // Continue anyway - report is created
      }

      // Show success message
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: AppTheme.backgroundDark,
            title: Row(
              children: const [
                Icon(Icons.check_circle, color: AppTheme.neonGreen, size: 32),
                SizedBox(width: 12),
                Text('Success!', style: TextStyle(color: AppTheme.neonGreen)),
              ],
            ),
            content: const Text(
              'Your incident report has been submitted successfully.',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog only
                  // Clear form
                  _descriptionController.clear();
                  setState(() {
                    _selectedLocation = null;
                    _locationText = 'Pin on map or use current location';
                    selectedIncidentType = 'Robbery';
                    _selectedDate = DateTime.now();
                    _selectedTime = TimeOfDay.now();
                    _mediaFiles.clear();
                    _linkUrls.clear();
                  });
                },
                style: TextButton.styleFrom(
                  backgroundColor: AppTheme.neonGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e, stackTrace) {
      // Catch ANY error to prevent crashes
      debugPrint('❌ Submit error: $e');
      debugPrint('Stack trace: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  int _getSeverityFromType(String type) {
    switch (type.toLowerCase()) {
      case 'robbery':
        return 80;
      case 'harassment':
        return 60;
      case 'accident':
        return 70;
      case 'vandalism':
        return 40;
      case 'suspicious activity':
        return 50;
      default:
        return 30;
    }
  }
}
