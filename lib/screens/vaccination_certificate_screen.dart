import 'package:flutter/material.dart';

import '../dialogs/vaccination_edit_dialog.dart';
import '../models/vaccination.dart';
import '../services/shared_prefs.dart';
import '../widgets/vaccination_card.dart';

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
    setState(() {
      vaccinations = fetchedVaccinations;
    });
  }

  Future<void> _editVaccination(int index) async {
    final editedVaccination = await showDialog<Vaccination>(
      context: context,
      builder: (BuildContext context) {
        return VaccinationEditDialog(vaccination: vaccinations[index]);
      },
    );

    if (editedVaccination != null) {
      setState(() {
        vaccinations[index] = editedVaccination;
      });

      // Update the specific vaccination in SharedPreferences
      await SharedPrefs.updateVaccination(
          vaccinations[index], editedVaccination);
    }
  }

  Future<void> _deleteVaccination(int index) async {
    final deletedVaccination = vaccinations[index];

    setState(() {
      vaccinations.removeAt(index);
    });

    // Remove the specific vaccination from SharedPreferences
    await SharedPrefs.removeVaccination(deletedVaccination);
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
                ),
              )
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
                      child: ListView.builder(
                        itemCount: vaccinations.length,
                        itemBuilder: (context, index) {
                          final vaccination = vaccinations[index];
                          return VaccinationCard(
                            vaccination: vaccination,
                            onEdit: () => _editVaccination(index),
                            onDelete: () => _deleteVaccination(index),
                          );
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
