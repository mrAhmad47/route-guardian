import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import '../theme/theme.dart';
import '../components/neon_card.dart';
import '../components/neon_button.dart';
import '../services/natlas_service.dart';
import 'incident_map_screen.dart';

class IncidentDetailsScreen extends StatefulWidget {
  const IncidentDetailsScreen({Key? key}) : super(key: key);

  @override
  State<IncidentDetailsScreen> createState() => _IncidentDetailsScreenState();
}

class _IncidentDetailsScreenState extends State<IncidentDetailsScreen> {
  final NAtlasService _natlasService = NAtlasService.instance;
  String _aiAnalysis = "Loading AI Analysis...";
  bool _isAnalyzing = true;
  String _currentLang = "English";

  // Mock data for the incident
  final String _incidentDescription =
      'A detailed description of the incident as reported by the user would be displayed here, providing context and specifics about the event. The report mentions a sudden confrontation near the main transit hub.';

  @override
  void initState() {
    super.initState();
    _fetchAnalysis();
  }

  Future<void> _fetchAnalysis() async {
    setState(() {
      _isAnalyzing = true;
    });
    // Call the AI service
    final result = await _natlasService.analyzeText(_incidentDescription);
    if (!mounted) return;
    setState(() {
      _aiAnalysis = result.isSuccessful 
          ? (result.summary.isNotEmpty ? result.summary : 'Incident analyzed: ${result.incidentType}')
          : 'Analysis unavailable';
      _isAnalyzing = false;
    });
  }
  
  Future<void> _translate(String lang) async {
      setState(() {
        _isAnalyzing = true;
        _currentLang = lang;
      });
      // For demo, simulate translation
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() {
        _aiAnalysis = "Translated Analysis ($lang): $_incidentDescription"; 
        _isAnalyzing = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: CustomScrollView(
        slivers: [
          // Custom App Bar as Sliver
          SliverAppBar(
            backgroundColor: AppTheme.backgroundDark.withOpacity(0.9),
            title: Text(
              'Incident Details',
              style: AppTheme.titleStyle.copyWith(
                color: AppTheme.neonGreen,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.ios_share, color: AppTheme.accentBlue),
                onPressed: () {},
              )
            ],
            pinned: true,
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Incident Summary Hero Card
                  NeonCard(
                    hasGlow: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.neonGreen.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'ASSAULT',
                                style: TextStyle(
                                  color: AppTheme.neonGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppTheme.accentBlue.withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.verified, size: 16, color: AppTheme.accentBlue),
                                  SizedBox(width: 4),
                                  Text(
                                    'N-ATLaS Verified', // Updated branding
                                    style: TextStyle(
                                      color: AppTheme.accentBlue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Sector 7 Cyber District',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Oct 26, 2023, 10:15 PM',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Risk Level: High',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        // Gradient risk bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                           child: Container(
                            height: 8,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.neonGreen,
                                  Colors.yellow,
                                  AppTheme.dangerRed,
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),

                  // AI Analysis Section (New)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                       color: AppTheme.secondaryBlack,
                       border: Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
                       borderRadius: BorderRadius.circular(8)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             Text("N-ATLaS AI Analysis", style: TextStyle(color: AppTheme.accentBlue, fontWeight: FontWeight.bold)),
                             if (_isAnalyzing)
                               const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentBlue)),
                           ],
                         ),
                         const SizedBox(height: 8),
                         Text(
                           _aiAnalysis,
                           style: const TextStyle(color: Colors.white70, fontSize: 13, fontStyle: FontStyle.italic),
                         ),
                         const SizedBox(height: 8),
                         // Language Switcher
                         Row(
                           mainAxisAlignment: MainAxisAlignment.end,
                           children: [
                             _buildLangButton("English"),
                             const SizedBox(width: 8),
                             _buildLangButton("Hausa"),
                             const SizedBox(width: 8),
                             _buildLangButton("Yoruba"),
                           ],
                         )
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Mini Map Preview
                  Container(
                    height: 220,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.neonGreen.withOpacity(0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.neonGreen.withOpacity(0.1),
                          blurRadius: 10,
                        )
                      ],
                      image: DecorationImage(
                        image: NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuCTJdMHAXs6pSqsNV6XCID1GpgsTQJghr41m-HA4lswaeKTgCKgbVY59RozyJI966Mf9etoYYluryf7uQnlo-Yib3_Z7RLXNvhYZzsRO9Hs161QNesGhe7Ovts_AP9HwDAe6kpdivCqzBR2WYmYLo6dXUOk75xRm7h9bAjFlvkab7l33o-7mTacnu8pMYkCdAA8fIYBTLRuhTJrlEFOefLs3qdxMtMPEWxwe7cpGwHNNOlSwzMNrALgpjnmc0dJGnQxzgco5ZaYCZFD"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                         const Align(
                           alignment: Alignment.center,
                           child: Icon(Icons.location_on, color: AppTheme.neonGreen, size: 48),
                         ),
                         Positioned(
                           bottom: 12,
                           right: 12,
                           child: ElevatedButton(
                             onPressed: () {
                               Navigator.push(
                                 context,
                                 MaterialPageRoute(
                                   builder: (context) => IncidentMapScreen(
                                     incidentType: 'ASSAULT',
                                     locationName: 'Sector 7 Cyber District',
                                     location: latlong2.LatLng(6.5244, 3.3792), // Sample location
                                     severity: 75,
                                     description: _incidentDescription,
                                   ),
                                 ),
                               );
                             },
                             style: ElevatedButton.styleFrom(
                               backgroundColor: Colors.black54,
                               foregroundColor: AppTheme.accentBlue,
                               side: const BorderSide(color: AppTheme.accentBlue),
                               shape: const StadiumBorder(),
                             ),
                             child: const Text('Open Full Map'),
                           ),
                         ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Description
                  Text(
                    'What Happened',
                    style: AppTheme.titleStyle.copyWith(color: AppTheme.neonGreen, fontSize: 18),
                  ),
                  const Divider(color: AppTheme.accentBlue, height: 24, thickness: 0.5),
                  Text(
                    _incidentDescription,
                    style: const TextStyle(color: Colors.white, height: 1.5),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Evidence
                  Container(
                    padding: const EdgeInsets.all(16),
                     decoration: BoxDecoration(
                       color: AppTheme.secondaryBlack.withOpacity(0.6),
                       borderRadius: BorderRadius.circular(16),
                       border: Border.all(color: AppTheme.neonGreen.withOpacity(0.2)),
                     ),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         const Text(
                           'Submitted Evidence',
                           style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                         ),
                         const SizedBox(height: 12),
                         Row(
                           children: [
                             Expanded(child: _buildEvidenceItem("10:16 PM", "https://lh3.googleusercontent.com/aida-public/AB6AXuDtLmHzcAMLygBStGAh8DVE0ImhHj-kGUAxYEqyj1VzsGCrXijeisAs3YtCQDx-lhmbZzC2NcE3gK6VBXTuRG1Sw7YT31upHMioavE7VyJBt3HZtHdbP_mWVn6HZafSump6xne28KCZmHedC6gMhMMdN5ySNt5bXWdYn2I4UJ7BAq8w2bZErTjLOTZ7WaNr-U6AUzIJrG5qE6RtyLWQqeyioOFCp_qHwkZPVhk7MX3RBn-RuXvlXd9tmNyubZjjODzWSUp9gl1Qioj3")),
                             const SizedBox(width: 12),
                             Expanded(child: _buildEvidenceItem("10:17 PM", "https://lh3.googleusercontent.com/aida-public/AB6AXuDZL_oVOYjQ9hvs6ItGeKLq1HkHbC41zANA8vvZgagjdtUbvyksanBYj-1uVYJG8kRkFvmPzMu1EevzsTsryLprPc96TGJ6icBlVvT1hKNX1z6K5VpH_cFh5QlU9807x-DrbfqA01rGNHBpgt1dZq7CdQisNVbFWetF0ptxuuZr4EQtbrI3vb_V2dIVEjnSxr2nlIrpu33Arf2WEEBop0JUSXU1HySZMwwnv8zsJ7WdjnorlNiSm40DF8DvtZxBMKwCQQyAnmPrfEMX")),
                           ],
                         )
                       ],
                     ),
                  ),

                  const SizedBox(height: 24),
                  
                  // Timeline
                  Text(
                    'Timeline',
                    style: AppTheme.titleStyle.copyWith(color: AppTheme.neonGreen, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  _buildTimelineItem('Report Submitted', 'Oct 26, 10:18 PM', isLast: false),
                  _buildTimelineItem('AI Analyzed', 'Oct 26, 10:19 PM', isLast: false),
                  _buildTimelineItem('Confidence Calculated', 'Oct 26, 10:21 PM', isLast: false),
                  _buildTimelineItem('Added to Safety Database', 'Oct 26, 10:22 PM', isLast: true),

                  const SizedBox(height: 24),
                  
                  // Confidence Score
                  NeonCard(
                    hasGlow: true,
                    child: Container(
                      width: double.infinity,
                      child: Column(
                        children: [
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                              children: [
                                const TextSpan(text: 'Severity Estimate: '),
                                TextSpan(text: 'Moderate (62%)', style: TextStyle(color: AppTheme.neonGreen)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Based on trend analysis + verified sources + news signals.',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Action Buttons (moved from floating position to here)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.neonGreen,
                            foregroundColor: Colors.black,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                          ),
                          child: const Text('Mark as Helpful', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.accentBlue,
                            side: const BorderSide(color: AppTheme.accentBlue),
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Report Inaccuracy', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLangButton(String lang) {
    bool isSelected = _currentLang == lang;
    return GestureDetector(
      onTap: () => _translate(lang),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentBlue.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.accentBlue : Colors.grey[800]!),
        ),
        child: Text(
          lang,
          style: TextStyle(
            color: isSelected ? AppTheme.accentBlue : Colors.grey,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildEvidenceItem(String time, String imageUrl) {
    return Container(
      height: 120, // fixed height for aspect ratio
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Text(time, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  const SizedBox(width: 4),
                  const Icon(Icons.open_in_new, size: 10, color: AppTheme.accentBlue),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String time, {required bool isLast}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Line and Dot
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppTheme.neonGreen.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.neonGreen, width: 2),
                  ),
                ),
                if (!isLast)
                   Expanded(
                     child: Container(
                       width: 2,
                       color: AppTheme.neonGreen.withOpacity(0.3),
                       margin: const EdgeInsets.only(bottom: 2),
                     ),
                   )
              ],
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
