// Hazard model round-trip — no Flutter binding / Firebase required.
import 'package:flutter_test/flutter_test.dart';
import 'package:klima/models/hazard.dart';

void main() {
  test('Hazard.fromJson maps fields and LatLng', () {
    final hazard = Hazard.fromJson({
      'id': 'h-1',
      'type': 'flood',
      'title': 'River overflow',
      'description': 'Water rising near the market',
      'latitude': 14.8527,
      'longitude': 120.8160,
      'barangay': 'Iba Este',
      'municipality': 'Calumpit',
      'province': 'Bulacan',
      'severity': 'high',
      'timestamp': '2026-07-25T10:00:00.000Z',
      'image_url': null,
      'source': 'pagasa',
      'is_verified': true,
      'upvotes': 3,
      'reports': 2,
    });

    expect(hazard.id, 'h-1');
    expect(hazard.type, 'flood');
    expect(hazard.location.latitude, closeTo(14.8527, 0.0001));
    expect(hazard.location.longitude, closeTo(120.8160, 0.0001));
    expect(hazard.isVerified, isTrue);
    expect(hazard.severity, 'high');
  });

  test('Hazard.toJson is invertible via fromJson', () {
    final original = Hazard.fromJson({
      'id': 'h-2',
      'type': 'typhoon',
      'title': 'Signal No. 2',
      'description': 'Strong winds expected',
      'latitude': 15.0,
      'longitude': 120.5,
      'barangay': 'Poblacion',
      'municipality': 'Malolos',
      'province': 'Bulacan',
      'severity': 'critical',
      'timestamp': '2026-07-25T12:00:00.000Z',
      'source': 'ndrrmc',
      'is_verified': false,
      'upvotes': 0,
      'reports': 1,
    });

    final roundTrip = Hazard.fromJson(original.toJson());
    expect(roundTrip.id, original.id);
    expect(roundTrip.title, original.title);
    expect(roundTrip.municipality, original.municipality);
    expect(roundTrip.source, original.source);
    expect(roundTrip.severity, original.severity);
  });
}
