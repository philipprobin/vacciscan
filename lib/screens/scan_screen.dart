import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import '../models/vaccination.dart';
import '../services/openai_api.dart';
import '../services/shared_prefs.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _images.add(File(image.path));
      });
    }
  }

  Future<void> _uploadImages() async {
    if (_images.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      List<Vaccination> allVaccinations = [];

      for (var image in _images) {
        String imagePath = image.path;

        // Convert the image to base64
        File imageFile = File(imagePath);
        String imageBase64 = base64Encode(await imageFile.readAsBytes());

        var result = await OpenAIApi().extractVaccineInfo(imageBase64);

        // Check the raw API response
        print('API Response: $result');

        // Navigate through the response to get the vaccinations data
        var toolCalls = result['choices'][0]['message']['tool_calls'];
        if (toolCalls == null || toolCalls.isEmpty) {
          print('No tool calls found in the response for image: $imagePath');
          continue; // Skip to the next image
        }

        var arguments = jsonDecode(toolCalls[0]['function']['arguments']);
        List<dynamic> vaccinationsData = arguments['vaccinations'] ?? [];

        if (vaccinationsData.isEmpty) {
          print('No vaccinations data found in the response for image: $imagePath');
          continue; // Handle the case when no data is available for the current image
        }

        List<Vaccination> vaccinations = vaccinationsData.map((v) {
          return Vaccination(
            brand: v['name_of_vaccine'] ?? 'Unknown',
            against: v['vaccination_against'] ?? 'Unknown',
            date: v['date'] ?? 'Unknown',
          );
        }).toList();

        allVaccinations.addAll(vaccinations);
      }

      if (allVaccinations.isNotEmpty) {
        // Save all vaccinations at once
        await SharedPrefs.addVaccinations(allVaccinations);
        HomeScreen.homeScreenKey.currentState?.setPage(0);
      } else {
        print('No vaccinations found in any of the images.');
      }
    } catch (e) {
      print('Error during API call: $e'); // This will give more insight into the error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  void _deleteImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Scan your vaccination certificate",
                    style:
                    TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                      ),
                      itemCount: _images.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onLongPress: () => _deleteImage(index),
                          child: Image.file(_images[index], fit: BoxFit.cover),
                        );
                      },
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (_images.isNotEmpty)
                        _buildCustomIconButton(
                          icon: Icons.upload,
                          onPressed: () => _uploadImages(),
                        ),
                      _buildCustomIconButton(
                        icon: Icons.camera_alt,
                        onPressed: () => _pickImage(ImageSource.camera),
                      ),
                      const SizedBox(width: 10),
                      _buildCustomIconButton(
                        icon: Icons.photo_library,
                        onPressed: () => _pickImage(ImageSource.gallery),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomIconButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.1),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
