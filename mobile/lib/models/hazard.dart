import 'package:latlong2/latlong.dart';

class Hazard {
  final String id;
  final String type; // flood, earthquake, landslide, typhoon, heatwave
  final String title;
  final String description;
  final LatLng location;
  final String barangay;
  final String municipality;
  final String province;
  final String severity; // low, moderate, high, critical
  final DateTime timestamp;
  final String? imageUrl;
  final String source; // citizen, pagasa, ndrrmc, lgu
  final bool isVerified;
  final int upvotes;
  final int reports;
  final Map<String, dynamic>? metadata;

  Hazard({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.location,
    required this.barangay,
    required this.municipality,
    required this.province,
    required this.severity,
    required this.timestamp,
    this.imageUrl,
    required this.source,
    this.isVerified = false,
    this.upvotes = 0,
    this.reports = 1,
    this.metadata,
  });

  factory Hazard.fromJson(Map<String, dynamic> json) {
    return Hazard(
      id: json['id'] ?? '',
      type: json['type'] ?? 'unknown',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: LatLng(
        json['latitude'] ?? 0.0,
        json['longitude'] ?? 0.0,
      ),
      barangay: json['barangay'] ?? '',
      municipality: json['municipality'] ?? '',
      province: json['province'] ?? '',
      severity: json['severity'] ?? 'moderate',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      imageUrl: json['image_url'],
      source: json['source'] ?? 'citizen',
      isVerified: json['is_verified'] ?? false,
      upvotes: json['upvotes'] ?? 0,
      reports: json['reports'] ?? 1,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'barangay': barangay,
      'municipality': municipality,
      'province': province,
      'severity': severity,
      'timestamp': timestamp.toIso8601String(),
      'image_url': imageUrl,
      'source': source,
      'is_verified': isVerified,
      'upvotes': upvotes,
      'reports': reports,
      'metadata': metadata,
    };
  }

  String get timeAgo {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  String get hazardIcon {
    switch (type.toLowerCase()) {
      case 'flood':
        return '🌊';
      case 'earthquake':
        return '🌋';
      case 'landslide':
        return '⛰️';
      case 'typhoon':
        return '🌀';
      case 'heatwave':
        return '☀️';
      case 'fire':
        return '🔥';
      default:
        return '⚠️';
    }
  }
}
