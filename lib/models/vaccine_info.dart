class VaccineInfo {
  final String disease;
  final String recommendations;

  VaccineInfo({required this.disease, required this.recommendations});

  factory VaccineInfo.fromJson(Map<String, dynamic> json) {
    return VaccineInfo(
      disease: json['Vaccines for disease'] as String,
      recommendations: json['Recommendations'] as String,
    );
  }
}
