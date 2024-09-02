// screens/travel_vaccination_screen.dart
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class TravelVaccinationScreen extends StatelessWidget {
  const TravelVaccinationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Vaccination'),
      ),
      body: const TravelVaccinationForm(),
    );
  }
}

class TravelVaccinationForm extends StatefulWidget {
  const TravelVaccinationForm({super.key});

  @override
  _TravelVaccinationFormState createState() => _TravelVaccinationFormState();
}

class _TravelVaccinationFormState extends State<TravelVaccinationForm> {
  final TextEditingController _controller = TextEditingController();
  List<String> vaccines = [];

  void fetchVaccines() async {
    final result = await FirebaseService.getVaccinesForCountries(_controller.text.split(','));
    setState(() {
      vaccines = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(labelText: 'Enter countries (comma separated)'),
          ),
          ElevatedButton(
            onPressed: fetchVaccines,
            child: const Text('Get Vaccinations'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: vaccines.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(vaccines[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
