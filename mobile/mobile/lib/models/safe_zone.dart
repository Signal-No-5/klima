import 'package:latlong2/latlong.dart';

class SafeZone {
  final String id;
  final String name;
  final String type; // evacuation_center, hospital, police_station, fire_station
  final LatLng location;
  final String address;
  final String barangay;
  final String municipality;
  final int capacity;
  final int currentOccupancy;
  final List<String> amenities;
  final String? contactNumber;
  final bool isOperational;
  final double? elevation; // meters above sea level
  final String? imageUrl;
  final Map<String, dynamic>? metadata;

  SafeZone({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.address,
    required this.barangay,
    required this.municipality,
    this.capacity = 0,
    this.currentOccupancy = 0,
    this.amenities = const [],
    this.contactNumber,
    this.isOperational = true,
    this.elevation,
    this.imageUrl,
    this.metadata,
  });

  factory SafeZone.fromJson(Map<String, dynamic> json) {
    return SafeZone(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'evacuation_center',
      location: LatLng(
        json['latitude'] ?? 0.0,
        json['longitude'] ?? 0.0,
      ),
      address: json['address'] ?? '',
      barangay: json['barangay'] ?? '',
      municipality: json['municipality'] ?? '',
      capacity: json['capacity'] ?? 0,
      currentOccupancy: json['current_occupancy'] ?? 0,
      amenities: json['amenities'] != null
          ? List<String>.from(json['amenities'])
          : [],
      contactNumber: json['contact_number'],
      isOperational: json['is_operational'] ?? true,
      elevation: json['elevation']?.toDouble(),
      imageUrl: json['image_url'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'address': address,
      'barangay': barangay,
      'municipality': municipality,
      'capacity': capacity,
      'current_occupancy': currentOccupancy,
      'amenities': amenities,
      'contact_number': contactNumber,
      'is_operational': isOperational,
      'elevation': elevation,
      'image_url': imageUrl,
      'metadata': metadata,
    };
  }

  double get occupancyPercentage {
    if (capacity == 0) return 0;
    return (currentOccupancy / capacity) * 100;
  }

  bool get hasSpace => currentOccupancy < capacity;

  String get typeIcon {
    switch (type) {
      case 'evacuation_center':
        return '🏫';
      case 'hospital':
        return '🏥';
      case 'police_station':
        return '👮';
      case 'fire_station':
        return '🚒';
      default:
        return '📍';
    }
  }
}
