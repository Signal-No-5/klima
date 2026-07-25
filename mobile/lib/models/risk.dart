class Risk {
  final String barangayId;
  final String barangayName;
  final String municipality;
  final double hazardScore; // 0-1
  final double exposureScore; // 0-1
  final double vulnerabilityScore; // 0-1
  final double riskScore; // composite score
  final String riskLevel; // low, moderate, high, critical
  final Map<String, double> hazardBreakdown; // flood: 0.8, landslide: 0.3, etc.
  final DateTime lastUpdated;
  final List<String> activeWarnings;
  final int safeResidents;
  final int totalPopulation;

  Risk({
    required this.barangayId,
    required this.barangayName,
    required this.municipality,
    required this.hazardScore,
    required this.exposureScore,
    required this.vulnerabilityScore,
    required this.riskScore,
    required this.riskLevel,
    this.hazardBreakdown = const {},
    required this.lastUpdated,
    this.activeWarnings = const [],
    this.safeResidents = 0,
    required this.totalPopulation,
  });

  factory Risk.fromJson(Map<String, dynamic> json) {
    return Risk(
      barangayId: json['barangay_id'] ?? '',
      barangayName: json['barangay_name'] ?? '',
      municipality: json['municipality'] ?? '',
      hazardScore: (json['hazard_score'] ?? 0).toDouble(),
      exposureScore: (json['exposure_score'] ?? 0).toDouble(),
      vulnerabilityScore: (json['vulnerability_score'] ?? 0).toDouble(),
      riskScore: (json['risk_score'] ?? 0).toDouble(),
      riskLevel: json['risk_level'] ?? 'low',
      hazardBreakdown: json['hazard_breakdown'] != null
          ? Map<String, double>.from(
              json['hazard_breakdown'].map(
                (key, value) => MapEntry(key, value.toDouble()),
              ),
            )
          : {},
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'])
          : DateTime.now(),
      activeWarnings: json['active_warnings'] != null
          ? List<String>.from(json['active_warnings'])
          : [],
      safeResidents: json['safe_residents'] ?? 0,
      totalPopulation: json['total_population'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'barangay_id': barangayId,
      'barangay_name': barangayName,
      'municipality': municipality,
      'hazard_score': hazardScore,
      'exposure_score': exposureScore,
      'vulnerability_score': vulnerabilityScore,
      'risk_score': riskScore,
      'risk_level': riskLevel,
      'hazard_breakdown': hazardBreakdown,
      'last_updated': lastUpdated.toIso8601String(),
      'active_warnings': activeWarnings,
      'safe_residents': safeResidents,
      'total_population': totalPopulation,
    };
  }

  double get safePercentage {
    if (totalPopulation == 0) return 0;
    return (safeResidents / totalPopulation) * 100;
  }
}
