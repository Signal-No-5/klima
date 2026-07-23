import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/safe_zone.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../providers/user_provider.dart';

class EvacuationRouteScreen extends StatefulWidget {
  const EvacuationRouteScreen({super.key});

  @override
  State<EvacuationRouteScreen> createState() => _EvacuationRouteScreenState();
}

class _EvacuationRouteScreenState extends State<EvacuationRouteScreen> {
  List<SafeZone> _safeZones = [];
  SafeZone? _selectedSafeZone;
  bool _isLoading = true;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = context.read<ApiService>();
      final locationService = context.read<LocationService>();
      final userProvider = context.read<UserProvider>();

      // Get current location
      final location = await locationService.getCurrentLocation();
      if (location != null) {
        _currentLocation = location.coordinates;
      }

      // Fetch safe zones
      _safeZones = await apiService.fetchSafeZones(
        municipality: userProvider.currentLocation?.municipality,
      );

      // Find nearest safe zone
      if (_safeZones.isNotEmpty && _currentLocation != null) {
        _selectedSafeZone = _findNearestSafeZone();
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  SafeZone _findNearestSafeZone() {
    SafeZone? nearest;
    double minDistance = double.infinity;

    for (final zone in _safeZones) {
      final distance = _calculateDistance(_currentLocation!, zone.location);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = zone;
      }
    }

    return nearest!;
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    const distance = Distance();
    return distance.as(LengthUnit.Meter, point1, point2);
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)}m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)}km';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentLocation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Evacuation Route')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Location permission needed'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🗺️ Evacuation Route'),
      ),
      body: Column(
        children: [
          // Map
          Expanded(
            flex: 2,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _currentLocation!,
                initialZoom: 14.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.klima.app',
                ),
                MarkerLayer(
                  markers: [
                    // Current location marker
                    Marker(
                      point: _currentLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                    // Safe zone markers
                    ..._safeZones.map((zone) {
                      return Marker(
                        point: zone.location,
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedSafeZone = zone;
                            });
                          },
                          child: Icon(
                            Icons.location_pin,
                            color: zone == _selectedSafeZone
                                ? Colors.red
                                : Colors.green,
                            size: 40,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),

          // Safe Zone Info
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: _selectedSafeZone != null
                  ? _buildSafeZoneInfo(_selectedSafeZone!)
                  : const Center(child: Text('Select a safe zone')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafeZoneInfo(SafeZone zone) {
    final distance = _calculateDistance(_currentLocation!, zone.location);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              zone.typeIcon,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    zone.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    zone.address,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildInfoChip(Icons.place, _formatDistance(distance)),
            const SizedBox(width: 8),
            _buildInfoChip(
                Icons.people, '${zone.currentOccupancy}/${zone.capacity}'),
            const SizedBox(width: 8),
            if (zone.elevation != null)
              _buildInfoChip(Icons.terrain, '${zone.elevation}m'),
          ],
        ),
        const SizedBox(height: 12),
        if (zone.contactNumber != null)
          Text(
            'Contact: ${zone.contactNumber}',
            style: const TextStyle(fontSize: 14),
          ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () {
            // In a real app, use maps integration
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Opening navigation...')),
            );
          },
          icon: const Icon(Icons.directions),
          label: const Text('Get Directions'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
