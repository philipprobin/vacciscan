// screens/photo_upload_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import '../services/photo_service.dart';

class PhotoUploadScreen extends StatelessWidget {
  const PhotoUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Photos'),
      ),
      body: const PhotoUploader(),
    );
  }
}

class PhotoUploader extends StatefulWidget {
  const PhotoUploader({super.key});

  @override
  _PhotoUploaderState createState() => _PhotoUploaderState();
}

class _PhotoUploaderState extends State<PhotoUploader> {
  List<String> photos = [];

  void addPhoto(String path) {
    setState(() {
      photos.add(path);
    });
  }

  void removePhoto(int index) {
    setState(() {
      photos.removeAt(index);
    });
  }

  void uploadAndAnalyze() async {
    final result = await PhotoService.analyzePhotos(photos);
    // Add the analysis result to your vaccination certificate
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            // Implement photo picker and add photo
          },
          child: const Text('Add Photo'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: photos.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Image.file(File(photos[index])),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => removePhoto(index),
                ),
              );
            },
          ),
        ),
        ElevatedButton(
          onPressed: uploadAndAnalyze,
          child: const Text('Upload and Analyze'),
        ),
      ],
    );
  }
}
