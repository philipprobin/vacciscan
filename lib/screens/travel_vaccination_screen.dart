import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/vaccination.dart';
import '../models/vaccine_info.dart';
import '../services/shared_prefs.dart';
import '../services/vaccine_info_helper.dart';
import '../util/app_colors.dart';
import '../util/lang_converter.dart';

class TravelVaccinationScreen extends StatelessWidget {
  const TravelVaccinationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: TravelVaccinationForm(),
    );
  }
}

class TravelVaccinationForm extends StatefulWidget {
  const TravelVaccinationForm({super.key});

  @override
  _TravelVaccinationFormState createState() => _TravelVaccinationFormState();
}

class _TravelVaccinationFormState extends State<TravelVaccinationForm> {
  String? selectedCountry;
  List<Map<String, String>> vaccines = [];
  final List<String> countries = [];
  List<String> _personalVaccines = [];

  @override
  void initState() {
    super.initState();
    loadCountries();
    loadPersonalVaccines();
  }

  Future<void> loadCountries() async {
    final String response = await rootBundle
        .loadString('lib/assets/vaccine_info/vaccine_info_en.json');
    final data = json.decode(response) as Map<String, dynamic>;

    setState(() {
      countries.addAll(data.keys);
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? country = prefs.getString('selectedCountry');
    if (country != null && countries.contains(country)) {
      setState(() {
        selectedCountry = country;
        fetchVaccines();
      });
    }
  }

  void fetchVaccines() async {
    if (selectedCountry != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedCountry', selectedCountry!);

      final List<VaccineInfo> result =
          await VaccineInfoHelper.getVaccineInfoForCountry(selectedCountry!);
      setState(() {
        vaccines = result
            .map((v) => {
                  'Vaccines for disease': v.disease,
                  'Recommendations': v.recommendations,
                })
            .toList();
      });
    }
  }

  Future<void> loadPersonalVaccines() async {
    List<Vaccination> personalVaccines =
        await SharedPrefs.fetchPersonalVaccines();
    List<String> diseases = [];
    for (Vaccination vaccine in personalVaccines) {
      diseases.add(vaccine.against);
    }
    setState(() {
      _personalVaccines = diseases;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Choose your destination country",
            style:
            TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          DropdownButton<String>(
            hint: const Text("Select a country"),
            value: selectedCountry,
            onChanged: (String? newValue) {
              setState(() {
                selectedCountry = newValue;
                fetchVaccines(); // Fetch vaccines automatically
              });
            },
            items: countries.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: vaccines.length,
              itemBuilder: (context, index) {
                final vaccineInfo = vaccines[index];
                final match = _personalVaccines.contains(
                  LangConverter
                      .diseaseTranslation[vaccineInfo['Vaccines for disease']],
                );

                return Card(
                  color: match ? AppColors.green : null,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title:
                        Text("Vaccine: ${vaccineInfo['Vaccines for disease']}"),
                    subtitle: Text(
                        "Recommendations: ${vaccineInfo['Recommendations']}"),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
