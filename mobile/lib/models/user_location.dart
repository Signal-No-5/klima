import 'package:latlong2/latlong.dart';

class UserLocation {
  final LatLng coordinates;
  final String? barangay;
  final String? municipality;
  final String? province;
  final double? accuracy;
  final DateTime timestamp;

  UserLocation({
    required this.coordinates,
    this.barangay,
    this.municipality,
    this.province,
    this.accuracy,
    required this.timestamp,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      coordinates: LatLng(
        json['latitude'] ?? 0.0,
        json['longitude'] ?? 0.0,
      ),
      barangay: json['barangay'],
      municipality: json['municipality'],
      province: json['province'],
      accuracy: json['accuracy']?.toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': coordinates.latitude,
      'longitude': coordinates.longitude,
      'barangay': barangay,
      'municipality': municipality,
      'province': province,
      'accuracy': accuracy,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  String get displayLocation {
    if (barangay != null && municipality != null) {
      return '$barangay, $municipality';
    } else if (municipality != null) {
      return municipality!;
    } else {
      return 'Unknown location';
    }
  }
}

class UserProfile {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final UserLocation? location;
  final String? barangayId;
  final bool isSafe;
  final DateTime? lastSafeUpdate;
  final int reportsSubmitted;
  final int helpRequestsSent;
  final List<String> badges;

  UserProfile({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.location,
    this.barangayId,
    this.isSafe = true,
    this.lastSafeUpdate,
    this.reportsSubmitted = 0,
    this.helpRequestsSent = 0,
    this.badges = const [],
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      location: json['location'] != null
          ? UserLocation.fromJson(json['location'])
          : null,
      barangayId: json['barangay_id'],
      isSafe: json['is_safe'] ?? true,
      lastSafeUpdate: json['last_safe_update'] != null
          ? DateTime.parse(json['last_safe_update'])
          : null,
      reportsSubmitted: json['reports_submitted'] ?? 0,
      helpRequestsSent: json['help_requests_sent'] ?? 0,
      badges: json['badges'] != null
          ? List<String>.from(json['badges'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'location': location?.toJson(),
      'barangay_id': barangayId,
      'is_safe': isSafe,
      'last_safe_update': lastSafeUpdate?.toIso8601String(),
      'reports_submitted': reportsSubmitted,
      'help_requests_sent': helpRequestsSent,
      'badges': badges,
    };
  }
}
