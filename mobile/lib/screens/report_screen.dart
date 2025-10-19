import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../models/report.dart';
import '../providers/report_provider.dart';
import '../providers/user_provider.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../constants/app_constants.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedHazardType;
  File? _imageFile;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedHazardType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a hazard type')),
      );
      return;
    }

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

      // Create report
      final report = Report(
        id: const Uuid().v4(),
        userId: userProvider.userProfile?.id ?? 'anonymous',
        userName: userProvider.userProfile?.name ?? 'Anonymous',
        type: AppConstants.reportTypeHazard,
        hazardType: _selectedHazardType,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: location.coordinates,
        barangay: location.barangay ?? '',
        municipality: location.municipality ?? '',
        timestamp: DateTime.now(),
        // In a real app, upload image to server and get URL
        imageUrl: _imageFile?.path,
      );

      // Submit report
      final success = await reportProvider.submitReport(report);

      if (success) {
        // Update user stats
        await userProvider.incrementReportsSubmitted();

        // Show notification
        await notificationService.showReportConfirmation();

        // Show success dialog
        if (mounted) {
          _showSuccessDialog();
        }
      } else {
        throw Exception('Failed to submit report');
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
              Icon(Icons.check_circle, color: Colors.green, size: 32),
              SizedBox(width: 12),
              Text('Salamat po!'),
            ],
          ),
          content: const Text(
            'Naitala na ang ulat ninyo. Nakatulong kayo sa inyong komunidad! 💙',
            style: TextStyle(fontSize: 16),
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
        title: const Text('📍 Mag-report ng Hazard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Card(
                color: Colors.blue.shade50,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 32),
                      SizedBox(height: 8),
                      Text(
                        'Tumulong sa inyong komunidad',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'I-report ang nakikita ninyong hazard',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Hazard Type Selection
              const Text(
                'Anong uri ng hazard?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.hazardTypes.map((type) {
                  final isSelected = _selectedHazardType == type;
                  return ChoiceChip(
                    label: Text(AppConstants.hazardTypeLabels[type] ?? type),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedHazardType = selected ? type : null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Pamagat ng report',
                  hintText: 'Halimbawa: Mataas na baha sa Sitio San Roque',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Detalye',
                  hintText: 'Describe the situation...',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Image
              if (_imageFile != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _imageFile!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _imageFile = null;
                          });
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),

              // Add Photo Button
              OutlinedButton.icon(
                onPressed: _showImageSourceDialog,
                icon: const Icon(Icons.add_a_photo),
                label: Text(_imageFile == null ? 'Add Photo' : 'Change Photo'),
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.orange,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'I-submit ang Report',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
