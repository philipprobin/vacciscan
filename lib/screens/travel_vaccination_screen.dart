import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/vaccination.dart';
import '../models/vaccine_info.dart';
import '../services/shared_prefs.dart';
import '../services/vaccine_info_helper.dart';
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
    final String response =
    await rootBundle.loadString('lib/assets/vaccine_info/vaccine_info_en.json');
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
          'importance': v.importance,
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
    // Group vaccines into categories
    Map<String, List<Map<String, String>>> groupedVaccines = {
      'red': [],
      'yellow': [],
      'green': [],
    };

    for (var vaccineInfo in vaccines) {
      final match = _personalVaccines.contains(vaccineInfo['Vaccines for disease'] ??"");

      if (match) {
        groupedVaccines['green']!.add(vaccineInfo);
      } else if (vaccineInfo['importance'] == 'high') {
        groupedVaccines['red']!.add(vaccineInfo);
      } else if (vaccineInfo['importance'] == 'low') {
        groupedVaccines['yellow']!.add(vaccineInfo);
      }
    }

    final groupTitles = [
      'Missing Vaccines',
      'Optional Vaccines',
      'Up-to-date Vaccines'
    ];
    final groupColors = [Colors.red, Colors.yellow, Colors.green];
    final groupIcons = [
      Icons.close, // Missing Vaccines
      Icons.info,  // Optional Vaccines
      Icons.check // Up-to-date Vaccines
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Title and Info Icon
          Row(
            children: [
              const Text(
                "Choose your destination country",
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8.0), // Space between text and icon
              IconButton(
                icon: const Icon(Icons.info_outline),
                tooltip: "Information source",
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Source Information"),
                        content: const Text(
                          "The data is sourced from the Centers for Disease Control and Prevention (CDC), "
                              "which is a U.S. federal public health agency under the Department of Health and Human Services.\n\n"
                              "For more information, visit: https://wwwnc.cdc.gov/travel/destinations/list",
                        ),
                        actions: [
                          TextButton(
                            child: const Text("Close"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          // Enhanced Dropdown Button
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.white,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: const Text("Select a country"),
                value: selectedCountry,
                icon: const Icon(Icons.arrow_drop_down),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCountry = newValue;
                    fetchVaccines(); // Fetch vaccines automatically
                  });
                },
                items: countries.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          // Vaccine Groups
          Expanded(
            child: groupedVaccines.values.every((group) => group.isEmpty)
                ? const Center(child: Text("No vaccine information available."))
                : ListView.builder(
              itemCount: groupTitles.length,
              itemBuilder: (context, index) {
                final vaccineGroup = groupedVaccines[
                index == 0 ? 'red' : index == 1 ? 'yellow' : 'green']!;

                if (vaccineGroup.isEmpty) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Card(
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: groupColors[index],
                        child: Icon(
                          groupIcons[index],
                          color: Colors.white,
                          size: 20.0,
                        ),
                      ),
                      title: Text(
                        groupTitles[index],
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      children: vaccineGroup.map((vaccine) {
                        return ListTile(
                          title: Text(
                            "${vaccine['Vaccines for disease']}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle:
                          Text("${vaccine['Recommendations']}"),
                        );
                      }).toList(),
                    ),
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
