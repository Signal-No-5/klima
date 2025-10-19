class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'http://localhost:8000'; // Change to your API URL
  static const String apiTimeout = '30';
  
  // API Endpoints
  static const String hazardLatestEndpoint = '/hazard/latest';
  static const String reportsEndpoint = '/reports';
  static const String riskEndpoint = '/risk';
  static const String safeZonesEndpoint = '/safezones';
  
  // Map Configuration
  static const double defaultZoom = 15.0;
  static const double maxZoom = 18.0;
  static const double minZoom = 5.0;
  
  // Calumpit Barangays
  static const List<String> calumpitBarangays = [
    'Balite',
    'Balungao',
    'Buguion',
    'Bulusan',
    'Calizon',
    'Caniogan',
    'Corazon',
    'Frances',
    'Gatbuca',
    'Gugo',
    'Iba Este',
    'Iba O\'Este',
    'Longos',
    'Meysulao',
    'Palimbang',
    'Panducot',
    'Pio Cruzcosa',
    'Pungo',
    'San Jose',
    'San Marcos',
    'Santa Lucia',
    'Santo Cristo',
    'Santo Niño',
    'Sapang Bayan',
  ];
  
  // Hazard Types
  static const List<String> hazardTypes = [
    'flood',
    'earthquake',
    'landslide',
    'typhoon',
    'heatwave',
    'fire',
  ];
  
  // Hazard Type Labels (Taglish)
  static const Map<String, String> hazardTypeLabels = {
    'flood': 'Baha',
    'earthquake': 'Lindol',
    'landslide': 'Pagguho ng Lupa',
    'typhoon': 'Bagyo',
    'heatwave': 'Sobrang Init',
    'fire': 'Sunog',
  };
  
  // Report Types
  static const String reportTypeHazard = 'hazard';
  static const String reportTypeHelp = 'help';
  static const String reportTypeSafe = 'safe';
  
  // Storage Keys
  static const String storageKeyUser = 'user_profile';
  static const String storageKeyGoBag = 'gobag_items';
  static const String storageKeyBadges = 'user_badges';
  static const String storageKeyLastLocation = 'last_location';
  
  // Notification Channels
  static const String notificationChannelAlerts = 'alerts';
  static const String notificationChannelReports = 'reports';
  static const String notificationChannelNudges = 'nudges';
  
  // Distance thresholds (in meters)
  static const double nearbyHazardRadius = 5000; // 5km
  static const double evacuationRouteMaxDistance = 10000; // 10km
  
  // Cache duration (in hours)
  static const int hazardCacheDuration = 1;
  static const int mapCacheDuration = 24;
}
