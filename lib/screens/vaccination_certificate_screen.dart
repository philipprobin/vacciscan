import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vaccination.dart';

class VaccinationCertificateScreen extends StatefulWidget {
  const VaccinationCertificateScreen({super.key});

  @override
  _VaccinationCertificateScreenState createState() => _VaccinationCertificateScreenState();
}

class _VaccinationCertificateScreenState extends State<VaccinationCertificateScreen> {
  List<Vaccination> vaccinations = [];

  @override
  void initState() {
    super.initState();
    _loadVaccinations();
  }

  Future<void> _loadVaccinations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? vaccinationsJson = prefs.getString('vaccinations');

    if (vaccinationsJson != null) {
      List<dynamic> vaccinationList = jsonDecode(vaccinationsJson);
      setState(() {
        vaccinations = vaccinationList.map((v) => Vaccination.fromJson(v)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vaccination Certificate')),
      body: vaccinations.isEmpty
          ? const Center(child: Text('No Vaccinations Found'))
          : ListView.builder(
        itemCount: vaccinations.length,
        itemBuilder: (context, index) {
          final vaccination = vaccinations[index];
          return VaccinationCard(vaccination: vaccination);
        },
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
      margin: const EdgeInsets.all(10.0),
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
