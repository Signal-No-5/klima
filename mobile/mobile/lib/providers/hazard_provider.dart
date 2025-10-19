import 'package:flutter/foundation.dart';
import '../models/hazard.dart';
import '../services/api_service.dart';

class HazardProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Hazard> _allHazards = [];
  List<Hazard> _nearbyHazards = [];
  List<Hazard> _officialHazards = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedHazardType;
  String? _selectedBarangay;

  List<Hazard> get allHazards => _allHazards;
  List<Hazard> get nearbyHazards => _nearbyHazards;
  List<Hazard> get officialHazards => _officialHazards;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedHazardType => _selectedHazardType;
  String? get selectedBarangay => _selectedBarangay;

  Future<void> fetchHazards({
    String? hazardType,
    String? barangay,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allHazards = await _apiService.fetchHazards(
        hazardType: hazardType,
        barangay: barangay,
      );

      // Filter hazards
      _filterHazards();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void _filterHazards() {
    // Official hazards from PAGASA, NDRRMC
    _officialHazards = _allHazards
        .where((h) => h.source == 'pagasa' || h.source == 'ndrrmc')
        .toList();

    // Sort all hazards by timestamp (most recent first)
    _allHazards.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    _officialHazards.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  void setNearbyHazards(List<Hazard> hazards) {
    _nearbyHazards = hazards;
    _nearbyHazards.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    notifyListeners();
  }

  void setHazardTypeFilter(String? hazardType) {
    _selectedHazardType = hazardType;
    notifyListeners();
    fetchHazards(hazardType: hazardType, barangay: _selectedBarangay);
  }

  void setBarangayFilter(String? barangay) {
    _selectedBarangay = barangay;
    notifyListeners();
    fetchHazards(hazardType: _selectedHazardType, barangay: barangay);
  }

  void clearFilters() {
    _selectedHazardType = null;
    _selectedBarangay = null;
    notifyListeners();
    fetchHazards();
  }

  List<Hazard> getFilteredHazards() {
    var filtered = List<Hazard>.from(_allHazards);

    if (_selectedHazardType != null) {
      filtered = filtered
          .where((h) => h.type.toLowerCase() == _selectedHazardType!.toLowerCase())
          .toList();
    }

    if (_selectedBarangay != null) {
      filtered = filtered
          .where((h) => h.barangay.toLowerCase() == _selectedBarangay!.toLowerCase())
          .toList();
    }

    return filtered;
  }

  // Get hazards by severity
  List<Hazard> getCriticalHazards() {
    return _allHazards
        .where((h) => h.severity == 'critical')
        .toList();
  }

  List<Hazard> getHighSeverityHazards() {
    return _allHazards
        .where((h) => h.severity == 'high' || h.severity == 'critical')
        .toList();
  }

  // Refresh hazards
  Future<void> refresh() async {
    await fetchHazards(
      hazardType: _selectedHazardType,
      barangay: _selectedBarangay,
    );
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
