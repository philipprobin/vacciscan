import 'package:flutter/material.dart';
import '../models/vaccination.dart';
import '../services/shared_prefs.dart';

class VaccinationCertificateScreen extends StatefulWidget {
  const VaccinationCertificateScreen({super.key});

  @override
  _VaccinationCertificateScreenState createState() =>
      _VaccinationCertificateScreenState();
}

class _VaccinationCertificateScreenState
    extends State<VaccinationCertificateScreen> {
  List<Vaccination> vaccinations = [];

  @override
  void initState() {
    super.initState();
    _loadVaccinations();
  }

  Future<void> _loadVaccinations() async {
    List<Vaccination> fetchedVaccinations =
        await SharedPrefs.fetchPersonalVaccines();
    if (fetchedVaccinations.isNotEmpty) {
      setState(() {
        vaccinations = fetchedVaccinations;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: vaccinations.isEmpty
            ? const Center(
                child: Text(
                'No Vaccinations Found',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ))
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "All Vaccinations",
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      // Wrap ListView.builder with Expanded
                      child: ListView.builder(
                        itemCount: vaccinations.length,
                        itemBuilder: (context, index) {
                          final vaccination = vaccinations[index];
                          return VaccinationCard(vaccination: vaccination);
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class VaccinationCard extends StatelessWidget {
  final Vaccination vaccination;

  const VaccinationCard({super.key, required this.vaccination});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 5,
      child: ListTile(
        contentPadding: const EdgeInsets.all(15.0),
        leading: const CircularIndicator(),
        title: Text(
          vaccination.brand,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(vaccination.against),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Date: ${vaccination.date}',
              style: const TextStyle(fontSize: 12.0, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class CircularIndicator extends StatelessWidget {
  const CircularIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue.withOpacity(0.2),
      ),
      child: Center(
        child: Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}
