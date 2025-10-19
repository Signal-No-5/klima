import 'package:latlong2/latlong.dart';

class Report {
  final String id;
  final String userId;
  final String userName;
  final String type; // hazard, help, safe
  final String? hazardType;
  final String title;
  final String description;
  final LatLng location;
  final String barangay;
  final String municipality;
  final DateTime timestamp;
  final String? imageUrl;
  final List<String>? imageUrls;
  final ReportStatus status;
  final String? responderNotes;
  final DateTime? respondedAt;

  Report({
    required this.id,
    required this.userId,
    required this.userName,
    required this.type,
    this.hazardType,
    required this.title,
    required this.description,
    required this.location,
    required this.barangay,
    required this.municipality,
    required this.timestamp,
    this.imageUrl,
    this.imageUrls,
    this.status = ReportStatus.pending,
    this.responderNotes,
    this.respondedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? 'Anonymous',
      type: json['type'] ?? 'hazard',
      hazardType: json['hazard_type'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: LatLng(
        json['latitude'] ?? 0.0,
        json['longitude'] ?? 0.0,
      ),
      barangay: json['barangay'] ?? '',
      municipality: json['municipality'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      imageUrl: json['image_url'],
      imageUrls: json['image_urls'] != null
          ? List<String>.from(json['image_urls'])
          : null,
      status: ReportStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReportStatus.pending,
      ),
      responderNotes: json['responder_notes'],
      respondedAt: json['responded_at'] != null
          ? DateTime.parse(json['responded_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'type': type,
      'hazard_type': hazardType,
      'title': title,
      'description': description,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'barangay': barangay,
      'municipality': municipality,
      'timestamp': timestamp.toIso8601String(),
      'image_url': imageUrl,
      'image_urls': imageUrls,
      'status': status.name,
      'responder_notes': responderNotes,
      'responded_at': respondedAt?.toIso8601String(),
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
}

enum ReportStatus {
  pending,
  verified,
  responding,
  resolved,
  dismissed,
}
