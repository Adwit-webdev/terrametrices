import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/geo_api_service.dart';
import '../services/location_service.dart';

class ReportHazardScreen extends StatefulWidget {
  const ReportHazardScreen({super.key});

  @override
  State<ReportHazardScreen> createState() => _ReportHazardScreenState();
}

class _ReportHazardScreenState extends State<ReportHazardScreen> {
  final ImagePicker _picker = ImagePicker();
  final GeoApiService _geoApiService = GeoApiService();
  final LocationService _locationService = LocationService();
  final TextEditingController _notesController = TextEditingController();

  File? _selectedImage;
  double _severity = 0.7;
  bool _isSubmitting = false;

  Future<void> _takePicture() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _selectedImage = File(photo.path);
      });
    }
  }

  Future<void> _submitReport() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final position = await _locationService.getCurrentPosition();
      final message = await _geoApiService.submitManualReport(
        latitude: position.latitude,
        longitude: position.longitude,
        severityScore: _severity,
        notes: _notesController.text.trim().isEmpty
            ? 'Captured from TerraMetrics AI Cam.'
            : _notesController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$message Image stays local because the current backend route only stores metadata.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _selectedImage = null;
        _severity = 0.7;
        _notesController.clear();
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: const Text('AI Structural Analysis'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.tealAccent[400],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blueGrey[700]!, width: 2),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 60,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'No Image Captured',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _notesController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Field notes for backend manual-report route',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.black45,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Severity score: ${_severity.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Slider(
                    value: _severity,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    activeColor: Colors.tealAccent[400],
                    onChanged: (value) {
                      setState(() {
                        _severity = value;
                      });
                    },
                  ),
                  const Text(
                    'The current backend route accepts location, severity, and notes. Captured image is kept on-device for now.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _takePicture,
              icon: const Icon(Icons.camera),
              label: const Text('Capture Road Hazard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent[400],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _isSubmitting ? null : _submitReport,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_upload),
              label: Text(
                _isSubmitting ? 'Submitting...' : 'Submit Manual Report',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
