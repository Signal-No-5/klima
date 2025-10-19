import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/report.dart';
import '../providers/report_provider.dart';
import '../providers/user_provider.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../constants/app_constants.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final _messageController = TextEditingController();
  String _selectedUrgency = 'moderate';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendHelpRequest() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final userProvider = context.read<UserProvider>();
      final reportProvider = context.read<ReportProvider>();
      final locationService = context.read<LocationService>();
      final notificationService = context.read<NotificationService>();

      // Get current location
      final location = await locationService.getCurrentLocation();
      if (location == null) {
        throw Exception('Unable to get location');
      }

      // Create help request
      final report = Report(
        id: const Uuid().v4(),
        userId: userProvider.userProfile?.id ?? 'anonymous',
        userName: userProvider.userProfile?.name ?? 'Anonymous',
        type: AppConstants.reportTypeHelp,
        title: 'HELP REQUEST - $_selectedUrgency',
        description: _messageController.text.trim().isEmpty
            ? 'Need assistance'
            : _messageController.text.trim(),
        location: location.coordinates,
        barangay: location.barangay ?? '',
        municipality: location.municipality ?? '',
        timestamp: DateTime.now(),
      );

      // Submit help request
      final success = await reportProvider.submitReport(report);

      if (success) {
        // Update user stats
        await userProvider.incrementHelpRequests();

        // Show notification
        await notificationService.showNotification(
          title: '🆘 Help Request Sent',
          body: 'Your request has been sent to responders.',
        );

        // Show success dialog
        if (mounted) {
          _showSuccessDialog();
        }
      } else {
        throw Exception('Failed to send help request');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.orange, size: 32),
              SizedBox(width: 12),
              Text('Request Sent'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your help request has been sent to:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.check, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Text('Barangay responders'),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.check, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Text('MDRRMO'),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.check, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Text('Emergency services'),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Help is on the way. Stay safe! 🙏',
                style: TextStyle(
                  color: Colors.black87,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to home
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🆘 Kailangan ng Tulong'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Warning Card
            Card(
              color: Colors.orange.shade50,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 48),
                    SizedBox(height: 12),
                    Text(
                      'Emergency Help Request',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This will send your location and request to emergency responders.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Urgency Level
            const Text(
              'Urgency Level',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'low',
                  label: Text('Low'),
                  icon: Icon(Icons.info_outline),
                ),
                ButtonSegment(
                  value: 'moderate',
                  label: Text('Moderate'),
                  icon: Icon(Icons.warning_amber),
                ),
                ButtonSegment(
                  value: 'high',
                  label: Text('High'),
                  icon: Icon(Icons.error_outline),
                ),
              ],
              selected: {_selectedUrgency},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedUrgency = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 24),

            // Message
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Message (optional)',
                hintText: 'Describe your situation...',
                prefixIcon: Icon(Icons.message),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),

            // Emergency Contacts
            const Text(
              'Emergency Hotlines',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildContactCard('911', 'National Emergency Hotline'),
            _buildContactCard('(044) 913-1234', 'Calumpit MDRRMO'),
            _buildContactCard('143', 'Red Cross'),
            const SizedBox(height: 24),

            // Send Help Button
            ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _sendHelpRequest,
              icon: const Icon(Icons.sos),
              label: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Send Help Request',
                      style: TextStyle(fontSize: 16),
                    ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(String number, String label) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.phone, color: Colors.green),
        title: Text(
          number,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(label),
        trailing: IconButton(
          icon: const Icon(Icons.call),
          onPressed: () {
            // In a real app, use url_launcher to call
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Calling $number...')),
            );
          },
        ),
      ),
    );
  }
}
