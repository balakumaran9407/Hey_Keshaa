import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';
import 'bluetooth_devices_screen.dart';
import '../screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 0,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              title: const Text(
                'Hey Keshaa',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.black),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            // Main Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Connection Status Card
                    _buildConnectionCard(),
                    const SizedBox(height: 24),

                    // Tab Indicators
                    _buildTabIndicators(),
                    const SizedBox(height: 20),

                    // Hair Health Score Section
                    _buildHairHealthSection(),
                    const SizedBox(height: 32),

                    // Quick Stats Section Header
                    const Text(
                      'Quick Stats',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick Stats Grid
                    _buildQuickStatsGrid(),
                    const SizedBox(height: 32),

                    // Analytics Section
                    _buildAnalyticsSection(),
                    const SizedBox(height: 32),

                    // Recommendations Section
                    _buildRecommendationsSection(),
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

  // ✅ Connection Status Card
  Widget _buildConnectionCard() {
    return Consumer<BluetoothServiceESP32>(
      builder: (context, btService, _) {
        return Container(
          decoration: BoxDecoration(
            color: btService.isConnected
                ? Colors.green[50]
                : const Color(0xFFFFEDED),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  btService.isConnected ? Colors.green[200]! : Colors.red[200]!,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: btService.isConnected ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        btService.isConnected ? 'Connected' : 'Not Connected',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: btService.isConnected
                              ? Colors.green[700]
                              : Colors.red[700],
                        ),
                      ),
                      if (btService.isConnected)
                        Text(
                          btService.deviceName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[600],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BluetoothDevicesScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.bluetooth),
                label: Text(btService.isConnected ? 'Disconnect' : 'Connect'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ Tab Indicators
  Widget _buildTabIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTabItem('Dashboard', 0),
        _buildTabItem('Temperature', 1),
        _buildTabItem('Moisture', 2),
      ],
    );
  }

  Widget _buildTabItem(String label, int index) {
    bool isActive = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
      },
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? const Color(0xFF6C63FF) : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          if (isActive)
            Container(
              width: 40,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }

  // ✅ Hair Health Section
  Widget _buildHairHealthSection() {
    return Consumer<BluetoothServiceESP32>(
      builder: (context, btService, _) {
        final score = btService.hairHealthScore;
        final statusColor = score > 70
            ? Colors.green[100]
            : score > 40
                ? Colors.yellow[100]
                : Colors.red[100];
        final statusTextColor = score > 70
            ? Colors.green[700]
            : score > 40
                ? Colors.orange[700]
                : Colors.red[700];

        return Container(
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Hair Health Score',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusTextColor!),
                    ),
                    child: Text(
                      '${score.toStringAsFixed(1)}/100',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: statusTextColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: score / 100,
                  minHeight: 8,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    score > 70
                        ? Colors.green
                        : score > 40
                            ? Colors.orange
                            : Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Status Message
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      score > 70
                          ? Icons.check_circle
                          : score > 40
                              ? Icons.info
                              : Icons.warning,
                      color: statusTextColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        score > 70
                            ? 'Your hair is healthy! Keep up the routine.'
                            : score > 40
                                ? 'Your hair needs some attention. Check recommendations.'
                                : 'Your hair needs urgent attention. Follow recommendations.',
                        style: TextStyle(
                          fontSize: 13,
                          color: statusTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ Quick Stats Grid
  Widget _buildQuickStatsGrid() {
    return Consumer<BluetoothServiceESP32>(
      builder: (context, btService, _) {
        return GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildQuickStatsCard(
              label: 'Temperature',
              value: '${btService.temperature.toStringAsFixed(1)}°C',
              icon: Icons.thermostat,
              backgroundColor: const Color(0xFFFFF3E0),
              iconColor: const Color(0xFFFFA500),
            ),
            _buildQuickStatsCard(
              label: 'Humidity',
              value: '${btService.humidity.toStringAsFixed(1)}%',
              icon: Icons.water_drop,
              backgroundColor: const Color(0xFFE3F2FD),
              iconColor: const Color(0xFF2196F3),
            ),
            _buildQuickStatsCard(
              label: 'Moisture',
              value: '${btService.moisture.toStringAsFixed(1)}%',
              icon: Icons.opacity,
              backgroundColor: const Color(0xFFE0F7FA),
              iconColor: const Color(0xFF00BCD4),
            ),
            _buildQuickStatsCard(
              label: 'Force',
              value: btService.accelerationX.toStringAsFixed(1),
              icon: Icons.circle_outlined,
              backgroundColor: const Color(0xFFF3E5F5),
              iconColor: const Color(0xFF9C27B0),
            ),
          ],
        );
      },
    );
  }

  // ✅ Quick Stats Card (Fixed Overflow)
  Widget _buildQuickStatsCard({
    required String label,
    required String value,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 28,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Analytics Section
  Widget _buildAnalyticsSection() {
    return Consumer<BluetoothServiceESP32>(
      builder: (context, btService, _) {
        final stats = btService.getAverageStats();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analytics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildAnalyticRow(
                    'Average Temperature',
                    '${stats['avgTemp']?.toStringAsFixed(1) ?? '0.0'}°C',
                    Colors.orange,
                  ),
                  const Divider(),
                  _buildAnalyticRow(
                    'Average Humidity',
                    '${stats['avgHumidity']?.toStringAsFixed(1) ?? '0.0'}%',
                    Colors.blue,
                  ),
                  const Divider(),
                  _buildAnalyticRow(
                    'Average Moisture',
                    '${stats['avgMoisture']?.toStringAsFixed(1) ?? '0.0'}%',
                    Colors.cyan,
                  ),
                  const Divider(),
                  _buildAnalyticRow(
                    'Total Readings',
                    '${btService.sensorHistory.length}',
                    Colors.purple,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnalyticRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Recommendations Section
  Widget _buildRecommendationsSection() {
    return Consumer<BluetoothServiceESP32>(
      builder: (context, btService, _) {
        final recommendations = <String>[];

        if (btService.temperature > 35) {
          recommendations.add('Your scalp is too hot. Use cool water rinse.');
        } else if (btService.temperature < 28) {
          recommendations
              .add('Your scalp is too cold. Improve blood circulation.');
        }

        if (btService.humidity > 70) {
          recommendations
              .add('High humidity detected. Use anti-frizz products.');
        } else if (btService.humidity < 40) {
          recommendations.add('Low humidity. Apply moisturizing treatments.');
        }

        if (btService.moisture > 80) {
          recommendations.add('Hair is too oily. Use dry shampoo.');
        } else if (btService.moisture < 30) {
          recommendations.add('Hair is too dry. Use deep conditioning mask.');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recommendations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            if (recommendations.isEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your hair health is optimal! No recommendations needed.',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: recommendations
                    .map((rec) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.amber[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.amber[200]!),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(Icons.lightbulb,
                                    color: Colors.amber[700], size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    rec,
                                    style: TextStyle(
                                      color: Colors.amber[900],
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ),
          ],
        );
      },
    );
  }
}
