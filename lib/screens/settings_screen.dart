import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  final bool _darkModeEnabled = false;
  String _updateFrequency = '1.5 seconds';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // General Section
            _buildSectionHeader('General'),
            _buildSettingsTile(
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Get alerts for hair health changes',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
                activeThumbColor: const Color(0xFF6C63FF),
              ),
            ),
            _buildSettingsTile(
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              subtitle: 'Coming soon',
              trailing: Switch(
                value: _darkModeEnabled,
                onChanged: null,
                activeThumbColor: const Color(0xFF6C63FF),
              ),
            ),

            // Data Section
            _buildSectionHeader('Data & Sync'),
            _buildSettingsTile(
              icon: Icons.schedule,
              title: 'Update Frequency',
              subtitle: _updateFrequency,
              onTap: () => _showUpdateFrequencyDialog(),
            ),
            _buildSettingsTile(
              icon: Icons.backup,
              title: 'Backup Data',
              subtitle: 'Backup to cloud',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Backup started...')),
                );
              },
            ),
            _buildSettingsTile(
              icon: Icons.delete,
              title: 'Clear History',
              subtitle: 'Delete all sensor readings',
              onTap: () => _showClearHistoryDialog(),
              isDestructive: true,
            ),

            // Device Section
            _buildSectionHeader('Device'),
            _buildSettingsTile(
              icon: Icons.bluetooth,
              title: 'Bluetooth Device',
              subtitle: 'HeyKeshaa_Comb',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _buildSettingsTile(
              icon: Icons.info,
              title: 'Device Info',
              subtitle: 'View device details',
              onTap: () => _showDeviceInfoDialog(),
            ),

            // About Section
            _buildSectionHeader('About'),
            _buildSettingsTile(
              icon: Icons.info_outline,
              title: 'App Version',
              subtitle: 'v2.4.1',
            ),
            _buildSettingsTile(
              icon: Icons.description,
              title: 'Privacy Policy',
              subtitle: 'View our privacy policy',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Opening privacy policy in browser...')),
                );
              },
            ),
            _buildSettingsTile(
              icon: Icons.help,
              title: 'Help & Support',
              subtitle: 'Get help using Hey Keshaa',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening support page...')),
                );
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red[50]
                : const Color(0xFF6C63FF).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : const Color(0xFF6C63FF),
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showUpdateFrequencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Frequency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFrequencyOption('0.5 seconds', '0.5s'),
            _buildFrequencyOption('1.5 seconds', '1.5s'),
            _buildFrequencyOption('3 seconds', '3s'),
            _buildFrequencyOption('5 seconds', '5s'),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyOption(String label, String value) {
    return RadioListTile<String>(
      title: Text(label),
      value: label,
      // ignore: deprecated_member_use
      groupValue: _updateFrequency,
      activeColor: const Color(0xFF6C63FF),
      // ignore: deprecated_member_use
      onChanged: (value) {
        setState(() {
          _updateFrequency = value ?? '1.5 seconds';
        });
        Navigator.pop(context);
      },
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History?'),
        content: const Text(
          'This will delete all sensor readings and cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History cleared')),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeviceInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Device Information'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Device Name: HeyKeshaa_Comb'),
            SizedBox(height: 8),
            Text('Device ID: ESP32-12345'),
            SizedBox(height: 8),
            Text('Firmware: v3.0'),
            SizedBox(height: 8),
            Text('BLE Status: Connected'),
            SizedBox(height: 8),
            Text('Signal Strength: -45 dBm'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
