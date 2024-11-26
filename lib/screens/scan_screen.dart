import 'dart:convert';
import 'dart:io';
import 'package:VaccineCheck/screens/vaccination_certificate_screen.dart';
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

  /// Modified _pickImage to handle multiple images when source is gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        final XFile? image = await _picker.pickImage(source: source);
        if (image != null) {
          setState(() {
            _images.add(File(image.path));
          });
        }
      } else if (source == ImageSource.gallery) {
        final List<XFile>? images = await _picker.pickMultiImage();
        if (images != null && images.isNotEmpty) {
          setState(() {
            _images.addAll(images.map((xfile) => File(xfile.path)).toList());
          });
        }
      }
    } catch (e) {
      // Handle any errors here
      print('Error picking images: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick images: $e')),
      );
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
        var toolCalls = result['choices']?[0]?['message']?['tool_calls'];
        if (toolCalls == null || toolCalls.isEmpty) {
          print('No tool calls found in the response for image: $imagePath');
          continue; // Skip to the next image
        }

        var arguments = jsonDecode(toolCalls[0]['function']['arguments']);
        List<dynamic> vaccinationsData = arguments['vaccinations'] ?? [];

        if (vaccinationsData.isEmpty) {
          print(
              'No vaccinations data found in the response for image: $imagePath');
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

        // Navigate to VaccinationCertificateScreen after analysis
        HomeScreen.homeScreenKey.currentState?.setPage(0);

      } else {
        print('No vaccinations found in any of the images.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No vaccinations found in the selected images.')),
        );
      }
    } catch (e) {
      print('Error during API call: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading images: $e')),
      );
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
                  // Instruction Text
                  const Text(
                    "Scan your vaccination certificate",
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16.0),
                  // Image Grid or Placeholder
                  Expanded(
                    child: _images.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.photo_library_outlined,
                                  size: 100,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16.0),
                                Text(
                                  "No images selected.\nTap the buttons below to add images.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 16.0, color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                            ),
                            itemCount: _images.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  GestureDetector(
                                    onLongPress: () => _deleteImage(index),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.file(
                                        _images[index],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _deleteImage(index),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 16.0),
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text("Gallery"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          textStyle: const TextStyle(fontSize: 16.0),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text("Camera"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          textStyle: const TextStyle(fontSize: 16.0),
                        ),
                      ),

                      if (_images.isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: _uploadImages,
                          icon: const Icon(Icons.upload_file),
                          label: const Text("Analyze"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                            textStyle: const TextStyle(fontSize: 16.0),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16.0),
                ],
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Updated _buildCustomIconButton to use ElevatedButton with icons and labels
// Removed the previous _buildCustomIconButton as it's no longer needed with the new design
}
