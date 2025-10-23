import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/notification_service.dart';

class SafeStatusScreen extends StatefulWidget {
  const SafeStatusScreen({super.key});

  @override
  State<SafeStatusScreen> createState() => _SafeStatusScreenState();
}

class _SafeStatusScreenState extends State<SafeStatusScreen> {
  bool _isUpdating = false;

  Future<void> _updateSafeStatus(bool isSafe) async {
    setState(() {
      _isUpdating = true;
    });

    ScaffoldMessengerState? messenger;
    try {
      final userProvider = context.read<UserProvider>();
      final notificationService = context.read<NotificationService>();

      messenger = ScaffoldMessenger.of(context);

      await userProvider.updateSafeStatus(isSafe);

      await notificationService.showNotification(
        title: isSafe ? '✅ Marked as Safe' : '⚠️ Status Updated',
        body: isSafe
            ? 'Salamat! Na-update na ang inyong status.'
            : 'Your community has been notified.',
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  isSafe ? Icons.check_circle : Icons.warning,
                  color: isSafe ? Colors.green : Colors.orange,
                  size: 32,
                ),
                const SizedBox(width: 12),
                const Text('Status Updated'),
              ],
            ),
            content: Text(
              isSafe
                  ? 'Salamat sa pag-update! Your status helps your community.'
                  : 'Stay safe! Help is available if needed.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted && messenger != null) {
        messenger.showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('✅ Safety Status'),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final isSafe = userProvider.userProfile?.isSafe ?? true;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: Colors.blue.shade50,
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 32),
                        SizedBox(height: 8),
                        Text(
                          'Update Your Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Let your barangay know if you\'re safe',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color:
                        isSafe ? Colors.green.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSafe ? Colors.green : Colors.orange,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        isSafe ? Icons.check_circle : Icons.warning,
                        size: 64,
                        color: isSafe ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isSafe ? 'You are SAFE' : 'Status: Need Attention',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isSafe ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _isUpdating ? null : () => _updateSafeStatus(true),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('I\'m Safe - Ligtas ako'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed:
                      _isUpdating ? null : () => _updateSafeStatus(false),
                  icon: const Icon(Icons.warning),
                  label: const Text('Need Assistance'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
