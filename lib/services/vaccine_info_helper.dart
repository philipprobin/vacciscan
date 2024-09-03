import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/vaccine_info.dart';

class VaccineInfoHelper {
  static Map<String, List<VaccineInfo>>? _cache;

  static Future<List<VaccineInfo>> getVaccineInfoForCountry(String country) async {
    // Check cache first
    if (_cache != null && _cache!.containsKey(country)) {
      return _cache![country]!;
    }

    // Load and parse JSON file
    final String response = await rootBundle.loadString('lib/assets/vaccine_info/vaccine_info_en.json');
    final data = json.decode(response) as Map<String, dynamic>;

    // Convert JSON to VaccineInfo objects
    final List<VaccineInfo> vaccineInfoList = (data[country] as List)
        .map((json) => VaccineInfo.fromJson(json as Map<String, dynamic>))
        .toList();

    // Cache the data
    _cache ??= {};
    _cache![country] = vaccineInfoList;

    return vaccineInfoList;
  }
}
