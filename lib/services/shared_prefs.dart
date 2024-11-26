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

  static Future<void> updateVaccination(
      Vaccination oldVaccination, Vaccination updatedVaccination) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? vaccinationsJson = prefs.getString('vaccinations');

    if (vaccinationsJson != null) {
      List<dynamic> vaccinationList = jsonDecode(vaccinationsJson);

      // Locate and update the vaccination
      for (int i = 0; i < vaccinationList.length; i++) {
        final current = vaccinationList[i];
        if (current['brand'] == oldVaccination.brand &&
            current['against'] == oldVaccination.against &&
            current['date'] == oldVaccination.date) {
          vaccinationList[i] = updatedVaccination.toJson();
          break;
        }
      }

      // Save the updated list
      await prefs.setString('vaccinations', jsonEncode(vaccinationList));
    }
  }

  static Future<void> removeVaccination(Vaccination vaccinationToRemove) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? vaccinationsJson = prefs.getString('vaccinations');

    if (vaccinationsJson != null) {
      List<dynamic> vaccinationList = jsonDecode(vaccinationsJson);

      // Remove the specific vaccination
      vaccinationList.removeWhere((current) =>
          current['brand'] == vaccinationToRemove.brand &&
          current['against'] == vaccinationToRemove.against &&
          current['date'] == vaccinationToRemove.date);

      // Save the updated list
      await prefs.setString('vaccinations', jsonEncode(vaccinationList));
    }
  }
}
