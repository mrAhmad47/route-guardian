import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../components/neon_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;
  bool _locationSharing = true;
  bool _anonymousReporting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              _buildProfileHeader(),
              
              const SizedBox(height: 24),
              
              // Stats Section
              _buildStatsSection(),
              
              const SizedBox(height: 24),
              
              // Settings Sections
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('ACCOUNT'),
                    const SizedBox(height: 12),
                    _buildSettingsCard([
                      _buildSettingItem(
                        icon: Icons.person_outline,
                        title: 'Edit Profile',
                        subtitle: 'Update your information',
                        onTap: () {},
                      ),
                      _buildSettingItem(
                        icon: Icons.shield_outlined,
                        title: 'Privacy Settings',
                        subtitle: 'Control your data visibility',
                        onTap: () {},
                      ),
                      _buildSettingItem(
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                        subtitle: 'Update your credentials',
                        onTap: () {},
                      ),
                    ]),
                    
                    const SizedBox(height: 24),
                    _buildSectionTitle('PREFERENCES'),
                    const SizedBox(height: 12),
                    _buildSettingsCard([
                      _buildToggleSetting(
                        icon: Icons.notifications_outlined,
                        title: 'Push Notifications',
                        subtitle: 'Alerts for nearby incidents',
                        value: _notificationsEnabled,
                        onChanged: (v) => setState(() => _notificationsEnabled = v),
                      ),
                      _buildToggleSetting(
                        icon: Icons.dark_mode_outlined,
                        title: 'Dark Mode',
                        subtitle: 'Always enabled for OPSEC',
                        value: _darkModeEnabled,
                        onChanged: (v) => setState(() => _darkModeEnabled = v),
                      ),
                      _buildToggleSetting(
                        icon: Icons.location_on_outlined,
                        title: 'Location Sharing',
                        subtitle: 'Share for better alerts',
                        value: _locationSharing,
                        onChanged: (v) => setState(() => _locationSharing = v),
                      ),
                      _buildToggleSetting(
                        icon: Icons.visibility_off_outlined,
                        title: 'Anonymous Reporting',
                        subtitle: 'Hide identity on reports',
                        value: _anonymousReporting,
                        onChanged: (v) => setState(() => _anonymousReporting = v),
                      ),
                    ]),
                    
                    const SizedBox(height: 24),
                    _buildSectionTitle('SUPPORT'),
                    const SizedBox(height: 12),
                    _buildSettingsCard([
                      _buildSettingItem(
                        icon: Icons.help_outline,
                        title: 'Help Center',
                        subtitle: 'Get help using the app',
                        onTap: () {},
                      ),
                      _buildSettingItem(
                        icon: Icons.feedback_outlined,
                        title: 'Send Feedback',
                        subtitle: 'Help us improve',
                        onTap: () {},
                      ),
                      _buildSettingItem(
                        icon: Icons.info_outline,
                        title: 'About RouteGuardian',
                        subtitle: 'Version 1.0.0',
                        onTap: () {},
                      ),
                    ]),
                    
                    const SizedBox(height: 24),
                    _buildSectionTitle('DANGER ZONE'),
                    const SizedBox(height: 12),
                    _buildSettingsCard([
                      _buildSettingItem(
                        icon: Icons.logout,
                        title: 'Sign Out',
                        subtitle: 'Log out of your account',
                        onTap: () => _showLogoutDialog(),
                        isDestructive: true,
                      ),
                      _buildSettingItem(
                        icon: Icons.delete_forever,
                        title: 'Delete Account',
                        subtitle: 'Permanently remove your data',
                        onTap: () => _showDeleteAccountDialog(),
                        isDestructive: true,
                      ),
                    ]),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.neonGreen.withOpacity(0.1),
            AppTheme.backgroundDark,
          ],
        ),
      ),
      child: Column(
        children: [
          // Profile Picture
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.neonGreen, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.neonGreen.withOpacity(0.4),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: AppTheme.backgroundDark,
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: AppTheme.neonGreen,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.backgroundDark, width: 3),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // User Name
          const Text(
            'Guardian User',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          
          // Email
          Text(
            'user@routeguardian.app',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          
          // Verified Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.neonGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.neonGreen.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.verified, size: 16, color: AppTheme.neonGreen),
                SizedBox(width: 4),
                Text(
                  'Verified Guardian',
                  style: TextStyle(
                    color: AppTheme.neonGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('12', 'Reports', Icons.flag)),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('48', 'Alerts', Icons.notifications)),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('156', 'Points', Icons.star)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.accentBlue, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.grey[500],
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.redAccent : AppTheme.neonGreen;
    
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDestructive ? Colors.redAccent : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSetting({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.neonGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.neonGreen, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.neonGreen,
            activeTrackColor: AppTheme.neonGreen.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white10),
        ),
        title: const Text(
          'Sign Out',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Signed out successfully')),
              );
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.redAccent),
        ),
        title: Row(
          children: const [
            Icon(Icons.warning, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Delete Account', style: TextStyle(color: Colors.redAccent)),
          ],
        ),
        content: const Text(
          'This action is irreversible. All your data, reports, and history will be permanently deleted.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion initiated'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            child: const Text('Delete Forever', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
