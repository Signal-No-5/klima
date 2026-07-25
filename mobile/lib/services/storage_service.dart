import 'package:hive/hive.dart';
import 'dart:convert';
import '../models/user_location.dart';
import '../models/gobag_item.dart';

class StorageService {
  static const String _userBox = 'user_data';
  static const String _goBagBox = 'gobag_data';
  static const String _cacheBox = 'cache_data';

  static Future<void> init() async {
    await Hive.openBox(_userBox);
    await Hive.openBox(_goBagBox);
    await Hive.openBox(_cacheBox);
  }

  // User Profile Storage
  static Future<void> saveUserProfile(UserProfile profile) async {
    final box = Hive.box(_userBox);
    await box.put('profile', json.encode(profile.toJson()));
  }

  static UserProfile? getUserProfile() {
    final box = Hive.box(_userBox);
    final data = box.get('profile');
    if (data != null) {
      return UserProfile.fromJson(json.decode(data));
    }
    return null;
  }

  // User Location Storage
  static Future<void> saveUserLocation(UserLocation location) async {
    final box = Hive.box(_userBox);
    await box.put('last_location', json.encode(location.toJson()));
  }

  static UserLocation? getLastUserLocation() {
    final box = Hive.box(_userBox);
    final data = box.get('last_location');
    if (data != null) {
      return UserLocation.fromJson(json.decode(data));
    }
    return null;
  }

  // Go-Bag Items Storage
  static Future<void> saveGoBagItems(List<GoBagItem> items) async {
    final box = Hive.box(_goBagBox);
    final jsonList = items.map((item) => json.encode(item.toJson())).toList();
    await box.put('items', jsonList);
  }

  static List<GoBagItem> getGoBagItems() {
    final box = Hive.box(_goBagBox);
    final data = box.get('items');
    if (data != null && data is List) {
      return data
          .map((item) => GoBagItem.fromJson(json.decode(item)))
          .toList();
    }
    return [];
  }

  static Future<void> updateGoBagItem(GoBagItem item) async {
    final items = getGoBagItems();
    final index = items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      items[index] = item;
      await saveGoBagItems(items);
    }
  }

  // Badges Storage
  static Future<void> saveBadges(List<String> badges) async {
    final box = Hive.box(_userBox);
    await box.put('badges', badges);
  }

  static List<String> getBadges() {
    final box = Hive.box(_userBox);
    final data = box.get('badges');
    if (data != null && data is List) {
      return List<String>.from(data);
    }
    return [];
  }

  static Future<void> addBadge(String badgeId) async {
    final badges = getBadges();
    if (!badges.contains(badgeId)) {
      badges.add(badgeId);
      await saveBadges(badges);
    }
  }

  // Learning Progress Storage
  static Future<void> saveLearningProgress(Map<String, dynamic> progress) async {
    final box = Hive.box(_userBox);
    await box.put('learning_progress', json.encode(progress));
  }

  static Map<String, dynamic> getLearningProgress() {
    final box = Hive.box(_userBox);
    final data = box.get('learning_progress');
    if (data != null) {
      return json.decode(data);
    }
    return {};
  }

  // Cache Management
  static Future<void> cacheData(String key, dynamic data) async {
    final box = Hive.box(_cacheBox);
    await box.put(key, {
      'data': json.encode(data),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static dynamic getCachedData(String key, {int maxAgeHours = 24}) {
    final box = Hive.box(_cacheBox);
    final cached = box.get(key);
    
    if (cached != null) {
      final timestamp = DateTime.parse(cached['timestamp']);
      final age = DateTime.now().difference(timestamp);
      
      if (age.inHours < maxAgeHours) {
        return json.decode(cached['data']);
      } else {
        // Clear expired cache
        box.delete(key);
      }
    }
    
    return null;
  }

  // Clear all data
  static Future<void> clearAll() async {
    await Hive.box(_userBox).clear();
    await Hive.box(_goBagBox).clear();
    await Hive.box(_cacheBox).clear();
  }

  // Clear cache only
  static Future<void> clearCache() async {
    await Hive.box(_cacheBox).clear();
  }
}
