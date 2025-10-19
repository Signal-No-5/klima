import 'package:flutter/foundation.dart';
import '../models/user_location.dart';
import '../services/storage_service.dart';

class UserProvider with ChangeNotifier {
  UserProfile? _userProfile;
  UserLocation? _currentLocation;

  UserProfile? get userProfile => _userProfile;
  UserLocation? get currentLocation => _currentLocation;

  Future<void> loadUserData() async {
    _userProfile = StorageService.getUserProfile();
    _currentLocation = StorageService.getLastUserLocation();
    
    // Create default profile if none exists
    if (_userProfile == null) {
      _userProfile = UserProfile(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'User',
        isSafe: true,
        badges: [],
      );
      await saveUserProfile();
    }
    
    notifyListeners();
  }

  Future<void> saveUserProfile() async {
    if (_userProfile != null) {
      await StorageService.saveUserProfile(_userProfile!);
      notifyListeners();
    }
  }

  Future<void> updateLocation(UserLocation location) async {
    _currentLocation = location;
    _userProfile = _userProfile?.copyWith(location: location);
    await StorageService.saveUserLocation(location);
    await saveUserProfile();
    notifyListeners();
  }

  Future<void> updateSafeStatus(bool isSafe) async {
    _userProfile = _userProfile?.copyWith(
      isSafe: isSafe,
      lastSafeUpdate: DateTime.now(),
    );
    await saveUserProfile();
    notifyListeners();
  }

  Future<void> incrementReportsSubmitted() async {
    _userProfile = _userProfile?.copyWith(
      reportsSubmitted: (_userProfile?.reportsSubmitted ?? 0) + 1,
    );
    await saveUserProfile();
    
    // Check for first report badge
    if (_userProfile!.reportsSubmitted == 1) {
      await addBadge('first_report');
    }
    
    notifyListeners();
  }

  Future<void> incrementHelpRequests() async {
    _userProfile = _userProfile?.copyWith(
      helpRequestsSent: (_userProfile?.helpRequestsSent ?? 0) + 1,
    );
    await saveUserProfile();
    notifyListeners();
  }

  Future<void> addBadge(String badgeId) async {
    if (_userProfile != null && !_userProfile!.badges.contains(badgeId)) {
      final updatedBadges = List<String>.from(_userProfile!.badges)..add(badgeId);
      _userProfile = _userProfile?.copyWith(badges: updatedBadges);
      await StorageService.addBadge(badgeId);
      await saveUserProfile();
      notifyListeners();
    }
  }

  Future<void> updateName(String name) async {
    _userProfile = _userProfile?.copyWith(name: name);
    await saveUserProfile();
    notifyListeners();
  }

  Future<void> updateContactInfo({String? email, String? phone}) async {
    _userProfile = _userProfile?.copyWith(
      email: email ?? _userProfile?.email,
      phone: phone ?? _userProfile?.phone,
    );
    await saveUserProfile();
    notifyListeners();
  }
}

extension UserProfileCopyWith on UserProfile {
  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserLocation? location,
    String? barangayId,
    bool? isSafe,
    DateTime? lastSafeUpdate,
    int? reportsSubmitted,
    int? helpRequestsSent,
    List<String>? badges,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      barangayId: barangayId ?? this.barangayId,
      isSafe: isSafe ?? this.isSafe,
      lastSafeUpdate: lastSafeUpdate ?? this.lastSafeUpdate,
      reportsSubmitted: reportsSubmitted ?? this.reportsSubmitted,
      helpRequestsSent: helpRequestsSent ?? this.helpRequestsSent,
      badges: badges ?? this.badges,
    );
  }
}
