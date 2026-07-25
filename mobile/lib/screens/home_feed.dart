import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hazard_provider.dart';
import '../providers/user_provider.dart';
import '../constants/app_theme.dart';
import '../constants/app_constants.dart';
import '../widgets/hazard_card.dart';
import '../widgets/floating_action_buttons.dart';
import 'report_screen.dart';
import 'help_screen.dart';
import 'safe_status_screen.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedHazardType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load data after first frame to avoid calling notifyListeners during build
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final hazardProvider = context.read<HazardProvider>();
    await hazardProvider.fetchHazards();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'KLIMA',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            SizedBox(width: 8),
            Text(
              '🌏',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navigate to notifications
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Para Sa\'yo'),
            Tab(text: 'My Location'),
            Tab(text: 'Official'),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildForYouTab(),
              _buildMyLocationTab(),
              _buildOfficialTab(),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: KlimaFloatingActionButtons(
              onReportTap: () => _navigateToReport(context),
              onHelpTap: () => _navigateToHelp(context),
              onSafeTap: () => _navigateToSafe(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForYouTab() {
    return Consumer<HazardProvider>(
      builder: (context, hazardProvider, child) {
        if (hazardProvider.isLoading && hazardProvider.allHazards.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (hazardProvider.error != null && hazardProvider.allHazards.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Oops! May problema sa pagkuha ng data.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        final hazards = _selectedHazardType != null
            ? hazardProvider.getFilteredHazards()
            : hazardProvider.allHazards;

        if (hazards.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🌤️', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text(
                  'All clear! Walang mga hazard report.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Stay safe and alert! 💙',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => hazardProvider.refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.only(
              top: 8,
              left: 8,
              right: 8,
              bottom: 100,
            ),
            itemCount: hazards.length,
            itemBuilder: (context, index) {
              return HazardCard(hazard: hazards[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildMyLocationTab() {
    return Consumer2<HazardProvider, UserProvider>(
      builder: (context, hazardProvider, userProvider, child) {
        final userLocation = userProvider.currentLocation;

        if (userLocation == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Location permission needed',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text('Enable location to see nearby hazards'),
              ],
            ),
          );
        }

        final nearbyHazards = hazardProvider.allHazards.where((hazard) {
          if (userLocation.barangay != null) {
            return hazard.barangay.toLowerCase() ==
                userLocation.barangay!.toLowerCase();
          }
          return false;
        }).toList();

        if (nearbyHazards.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('✅', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text(
                  'Your area is safe!',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'No hazards reported in ${userLocation.barangay}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => hazardProvider.refresh(),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: AppTheme.primaryBlue.withAlpha((0.1 * 255).round()),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: AppTheme.primaryBlue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        userLocation.displayLocation,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Chip(
                      label: Text('${nearbyHazards.length} alerts'),
                      backgroundColor: AppTheme.warningYellow,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(
                    top: 8,
                    left: 8,
                    right: 8,
                    bottom: 100,
                  ),
                  itemCount: nearbyHazards.length,
                  itemBuilder: (context, index) {
                    return HazardCard(hazard: nearbyHazards[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOfficialTab() {
    return Consumer<HazardProvider>(
      builder: (context, hazardProvider, child) {
        final officialHazards = hazardProvider.officialHazards;

        if (officialHazards.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('📡', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text(
                  'No official bulletins',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text('Check back later for updates from PAGASA & NDRRMC'),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => hazardProvider.refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.only(
              top: 8,
              left: 8,
              right: 8,
              bottom: 100,
            ),
            itemCount: officialHazards.length,
            itemBuilder: (context, index) {
              return HazardCard(
                hazard: officialHazards[index],
                showVerifiedBadge: true,
              );
            },
          ),
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Hazards'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Hazard Type:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _selectedHazardType == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedHazardType = null;
                      });
                      context.read<HazardProvider>().clearFilters();
                      Navigator.pop(context);
                    },
                  ),
                  ...AppConstants.hazardTypes.map((type) {
                    return FilterChip(
                      label: Text(AppConstants.hazardTypeLabels[type] ?? type),
                      selected: _selectedHazardType == type,
                      onSelected: (selected) {
                        setState(() {
                          _selectedHazardType = selected ? type : null;
                        });
                        context
                            .read<HazardProvider>()
                            .setHazardTypeFilter(_selectedHazardType);
                        Navigator.pop(context);
                      },
                    );
                  }),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedHazardType = null;
                });
                context.read<HazardProvider>().clearFilters();
                Navigator.pop(context);
              },
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToReport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReportScreen()),
    );
  }

  void _navigateToHelp(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HelpScreen()),
    );
  }

  void _navigateToSafe(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SafeStatusScreen()),
    );
  }
}
