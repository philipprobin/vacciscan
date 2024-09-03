import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/vaccination.dart';

class SharedPrefs {

  static Future<List<Vaccination>> fetchPersonalVaccines() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? vaccinationsJson = prefs.getString('vaccinations');
    if (vaccinationsJson != null) {
      List<dynamic> vaccinationList = jsonDecode(vaccinationsJson);
      List<Vaccination> vaccinations =
      vaccinationList.map((v) => Vaccination.fromJson(v)).toList();
      return vaccinations;
    }
    return [];
  }

  static Future<void> addVaccinations(List<Vaccination> newVaccinations) async {
    List<Vaccination> existingVaccinations = await fetchPersonalVaccines();

    // Filter out duplicates
    for (var newVaccine in newVaccinations) {
      bool isDuplicate = existingVaccinations.any((existingVaccine) =>
      existingVaccine.brand == newVaccine.brand &&
          existingVaccine.against == newVaccine.against &&
          existingVaccine.date == newVaccine.date);
      if (!isDuplicate) {
        existingVaccinations.add(newVaccine);
      }
    }

    // Save the updated list
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('vaccinations', jsonEncode(existingVaccinations));
  }
}
