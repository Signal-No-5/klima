import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/hazard.dart';
import '../models/report.dart';
import '../models/risk.dart';
import '../models/safe_zone.dart';
import '../models/community_post.dart';
import '../constants/app_constants.dart';

class ApiService {
  final String baseUrl;
  final http.Client _client;

  ApiService({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? AppConstants.apiBaseUrl,
        _client = client ?? http.Client();

  // Headers
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Fetch latest hazards
  Future<List<Hazard>> fetchHazards({
    String? hazardType,
    String? barangay,
    String? municipality,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (hazardType != null) queryParams['type'] = hazardType;
      if (barangay != null) queryParams['barangay'] = barangay;
      if (municipality != null) queryParams['municipality'] = municipality;

      final uri = Uri.parse('$baseUrl${AppConstants.hazardLatestEndpoint}')
          .replace(queryParameters: queryParams);

      final response = await _client.get(uri, headers: _headers).timeout(
            Duration(seconds: int.parse(AppConstants.apiTimeout)),
          );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Hazard.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load hazards: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching hazards: $e');
      // Return mock data for development
      return _getMockHazards();
    }
  }

  // Submit a report
  Future<Report> submitReport(Report report) async {
    try {
      final uri = Uri.parse('$baseUrl${AppConstants.reportsEndpoint}');
      final response = await _client
          .post(
            uri,
            headers: _headers,
            body: json.encode(report.toJson()),
          )
          .timeout(
            Duration(seconds: int.parse(AppConstants.apiTimeout)),
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Report.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to submit report: ${response.statusCode}');
      }
    } catch (e) {
      print('Error submitting report: $e');
      // Return the report as-is for offline mode
      return report;
    }
  }

  // Fetch reports
  Future<List<Report>> fetchReports({
    String? type,
    String? barangay,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (type != null) queryParams['type'] = type;
      if (barangay != null) queryParams['barangay'] = barangay;

      final uri = Uri.parse('$baseUrl${AppConstants.reportsEndpoint}')
          .replace(queryParameters: queryParams);

      final response = await _client.get(uri, headers: _headers).timeout(
            Duration(seconds: int.parse(AppConstants.apiTimeout)),
          );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Report.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load reports: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching reports: $e');
      return [];
    }
  }

  // Fetch risk data for a barangay
  Future<Risk?> fetchRisk(String barangayId) async {
    try {
      final uri = Uri.parse('$baseUrl${AppConstants.riskEndpoint}/$barangayId');
      final response = await _client.get(uri, headers: _headers).timeout(
            Duration(seconds: int.parse(AppConstants.apiTimeout)),
          );

      if (response.statusCode == 200) {
        return Risk.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load risk data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching risk: $e');
      return null;
    }
  }

  // Fetch safe zones
  Future<List<SafeZone>> fetchSafeZones({
    String? barangay,
    String? municipality,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (barangay != null) queryParams['barangay'] = barangay;
      if (municipality != null) queryParams['municipality'] = municipality;

      final uri = Uri.parse('$baseUrl${AppConstants.safeZonesEndpoint}')
          .replace(queryParameters: queryParams);

      final response = await _client.get(uri, headers: _headers).timeout(
            Duration(seconds: int.parse(AppConstants.apiTimeout)),
          );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => SafeZone.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load safe zones: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching safe zones: $e');
      return _getMockSafeZones();
    }
  }

  // Fetch community posts
  Future<List<CommunityPost>> fetchCommunityPosts({
    String? barangay,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (barangay != null) queryParams['barangay'] = barangay;

      final uri = Uri.parse('$baseUrl/community/posts')
          .replace(queryParameters: queryParams);

      final response = await _client.get(uri, headers: _headers).timeout(
            Duration(seconds: int.parse(AppConstants.apiTimeout)),
          );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => CommunityPost.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load community posts: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching community posts: $e');
      return _getMockCommunityPosts();
    }
  }

  // Mock data for development/offline mode
  List<Hazard> _getMockHazards() {
    return [
      Hazard(
        id: '1',
        type: 'flood',
        title: 'Mataas na baha sa Iba Este',
        description:
            'Umabot na sa tuhod ang tubig sa Sitio San Roque. Mahirap makalabas.',
        location: const LatLng(14.9167, 120.7667),
        barangay: 'Iba Este',
        municipality: 'Calumpit',
        province: 'Bulacan',
        severity: 'high',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        source: 'citizen',
        isVerified: true,
        upvotes: 12,
        reports: 5,
      ),
      Hazard(
        id: '2',
        type: 'flood',
        title: 'Blocked Road - Caniogan',
        description: 'Hindi madaanan ang kalsada dahil sa baha at debris.',
        location: const LatLng(14.9200, 120.7600),
        barangay: 'Caniogan',
        municipality: 'Calumpit',
        province: 'Bulacan',
        severity: 'moderate',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        source: 'citizen',
        isVerified: false,
        upvotes: 8,
        reports: 3,
      ),
      Hazard(
        id: '3',
        type: 'typhoon',
        title: 'Typhoon Signal #3 - Bulacan',
        description:
            'PAGASA: Typhoon "Egay" is expected to make landfall in Central Luzon.',
        location: const LatLng(14.9167, 120.7667),
        barangay: '',
        municipality: 'Calumpit',
        province: 'Bulacan',
        severity: 'critical',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        source: 'pagasa',
        isVerified: true,
        upvotes: 45,
        reports: 1,
      ),
    ];
  }

  List<SafeZone> _getMockSafeZones() {
    return [
      SafeZone(
        id: '1',
        name: 'Calumpit National High School',
        type: 'evacuation_center',
        location: const LatLng(14.9180, 120.7650),
        address: 'Iba Este, Calumpit, Bulacan',
        barangay: 'Iba Este',
        municipality: 'Calumpit',
        capacity: 500,
        currentOccupancy: 120,
        amenities: ['Water', 'Food', 'Medical', 'Toilets'],
        contactNumber: '(044) 913-1234',
        isOperational: true,
        elevation: 12.5,
      ),
      SafeZone(
        id: '2',
        name: 'Barangay Hall - Santo Niño',
        type: 'evacuation_center',
        location: const LatLng(14.9100, 120.7700),
        address: 'Santo Niño, Calumpit, Bulacan',
        barangay: 'Santo Niño',
        municipality: 'Calumpit',
        capacity: 200,
        currentOccupancy: 45,
        amenities: ['Water', 'Toilets'],
        contactNumber: '(044) 913-5678',
        isOperational: true,
        elevation: 10.0,
      ),
      SafeZone(
        id: '3',
        name: 'Calumpit District Hospital',
        type: 'hospital',
        location: const LatLng(14.9150, 120.7680),
        address: 'Poblacion, Calumpit, Bulacan',
        barangay: 'Poblacion',
        municipality: 'Calumpit',
        capacity: 100,
        currentOccupancy: 30,
        amenities: ['Medical', 'Emergency Room', 'Ambulance'],
        contactNumber: '(044) 913-9999',
        isOperational: true,
        elevation: 15.0,
      ),
    ];
  }

  List<CommunityPost> _getMockCommunityPosts() {
    return [
      CommunityPost(
        id: '1',
        title: 'Relief Operations Schedule',
        content:
            'Magkakaroon ng relief distribution bukas, June 15, 8:00 AM sa Barangay Hall. Magdala ng valid ID.',
        authorName: 'Calumpit LGU',
        authorType: 'lgu',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        tags: ['relief', 'schedule'],
        isPinned: true,
      ),
      CommunityPost(
        id: '2',
        title: 'Road Clearing Update',
        content:
            'Tapos na ang clearing operations sa C. Mercado Street. Pwede na dumaan ang mga sasakyan.',
        authorName: 'MDRRMO Calumpit',
        authorType: 'lgu',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        tags: ['update', 'road'],
      ),
    ];
  }

  void dispose() {
    _client.close();
  }
}
