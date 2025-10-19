import 'package:flutter/foundation.dart';
import '../models/report.dart';
import '../services/api_service.dart';

class ReportProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Report> _reports = [];
  List<Report> _myReports = [];
  bool _isLoading = false;
  String? _error;

  List<Report> get reports => _reports;
  List<Report> get myReports => _myReports;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchReports({
    String? type,
    String? barangay,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reports = await _apiService.fetchReports(
        type: type,
        barangay: barangay,
      );

      // Sort by timestamp (most recent first)
      _reports.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitReport(Report report) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final submittedReport = await _apiService.submitReport(report);
      
      // Add to reports list
      _reports.insert(0, submittedReport);
      _myReports.insert(0, submittedReport);

      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      
      return false;
    }
  }

  void addLocalReport(Report report) {
    _reports.insert(0, report);
    _myReports.insert(0, report);
    notifyListeners();
  }

  List<Report> getReportsByType(String type) {
    return _reports.where((r) => r.type == type).toList();
  }

  List<Report> getHelpRequests() {
    return _reports
        .where((r) => r.type == 'help' && r.status == ReportStatus.pending)
        .toList();
  }

  List<Report> getSafeReports() {
    return _reports.where((r) => r.type == 'safe').toList();
  }

  List<Report> getPendingReports() {
    return _reports.where((r) => r.status == ReportStatus.pending).toList();
  }

  Future<void> refresh() async {
    await fetchReports();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
