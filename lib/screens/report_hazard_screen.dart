import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ReportHazardScreen extends StatefulWidget {
  const ReportHazardScreen({super.key});

  @override
  State<ReportHazardScreen> createState() => _ReportHazardScreenState();
}

class _ReportHazardScreenState extends State<ReportHazardScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Function to open the camera and snap a picture
  Future<void> _takePicture() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _selectedImage = File(photo.path);
      });
    }
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display the image if we have one, otherwise show a placeholder
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
                          Icon(Icons.camera_alt_outlined, size: 60, color: Colors.grey),
                          SizedBox(height: 10),
                          Text('No Image Captured', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
              ),
              const SizedBox(height: 40),
              
              // The Camera Button
              ElevatedButton.icon(
                onPressed: _takePicture,
                icon: const Icon(Icons.camera),
                label: const Text('Capture Road Hazard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent[400],
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              // The "Submit" Button (Only shows if an image is taken)
              if (_selectedImage != null)
                OutlinedButton.icon(
                  onPressed: () {
                    // For the MVP demo, we just show a success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Image submitted to AI Computer Vision model.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    setState(() => _selectedImage = null); // Reset after submitting
                  },
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Submit for AI Processing'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.tealAccent),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}