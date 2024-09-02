import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vacciscan/screens/vaccination_certificate_screen.dart';
import '../models/vaccination.dart';
import '../services/openai_api.dart';

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
      String imagePath = _images.first.path;

      // Convert the image to base64
      File imageFile = File(imagePath);
      String imageBase64 = base64Encode(await imageFile.readAsBytes());

      var result = await OpenAIApi().extractVaccineInfo(imageBase64);

      // Check the raw API response
      print('API Response: $result');

      // Navigate through the response to get the vaccinations data
      var toolCalls = result['choices'][0]['message']['tool_calls'];
      if (toolCalls == null || toolCalls.isEmpty) {
        print('No tool calls found in the response.');
        return;
      }

      var arguments = jsonDecode(toolCalls[0]['function']['arguments']);
      List<dynamic> vaccinationsData = arguments['vaccinations'] ?? [];

      if (vaccinationsData.isEmpty) {
        print('No vaccinations data found in the response.');
        return; // Handle the case when no data is available
      }

      List<Vaccination> vaccinations = vaccinationsData.map((v) {
        return Vaccination(
          v['name_of_vaccine'] ?? 'Unknown',
          v['vaccination_against'] ?? 'Unknown',
          v['date'] ?? 'Unknown',
        );
      }).toList();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('vaccinations', jsonEncode(vaccinations));

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const VaccinationCertificateScreen()),
      );
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
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Vaccination Certificate')),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
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
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomIconButton({required IconData icon, required VoidCallback onPressed}) {
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
