import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../constants/mock_data.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final profile = userProvider.userProfile;
          if (profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final allBadges = MockData.getBadges();
          final userBadges = allBadges.where((b) => profile.badges.contains(b['id'])).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          child: Icon(Icons.person, size: 50),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          profile.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (profile.location != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_on, size: 16),
                              const SizedBox(width: 4),
                              Text(profile.location!.displayLocation),
                            ],
                          ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: profile.isSafe
                                ? Colors.green.shade100
                                : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                profile.isSafe ? Icons.check_circle : Icons.warning,
                                size: 16,
                                color: profile.isSafe ? Colors.green : Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                profile.isSafe ? 'Safe' : 'Need Attention',
                                style: TextStyle(
                                  color: profile.isSafe ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Statistics
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Contributions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatColumn(
                              icon: Icons.report,
                              count: profile.reportsSubmitted,
                              label: 'Reports',
                            ),
                            _buildStatColumn(
                              icon: Icons.sos,
                              count: profile.helpRequestsSent,
                              label: 'Help Requests',
                            ),
                            _buildStatColumn(
                              icon: Icons.emoji_events,
                              count: profile.badges.length,
                              label: 'Badges',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Badges
                if (userBadges.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Badges Earned',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: userBadges.map((badge) {
                              return _buildBadge(badge);
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Settings & Actions
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.settings),
                        title: const Text('Settings'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: const Icon(Icons.help),
                        title: const Text('Help & Support'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: const Icon(Icons.info),
                        title: const Text('About KLIMA'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          _showAboutDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatColumn({
    required IconData icon,
    required int count,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(Map<String, dynamic> badge) {
    return Tooltip(
      message: badge['description'],
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          border: Border.all(color: Colors.amber),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              badge['icon'],
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 4),
            Text(
              badge['name'],
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'KLIMA',
      applicationVersion: '1.0.0',
      applicationIcon: const Text('🌏', style: TextStyle(fontSize: 32)),
      children: [
        const Text(
          'The People\'s DRRM App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('Real-time alerts. Local insights.'),
        const Text('From "report" to "rescue," built for bayanihan and resilience.'),
        const SizedBox(height: 16),
        const Text('© 2025 KLIMA Project'),
      ],
    );
  }
}
