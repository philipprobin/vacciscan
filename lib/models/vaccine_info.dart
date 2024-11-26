class VaccineInfo {
  final String disease;
  final String recommendations;
  final String importance;

  VaccineInfo(
      {required this.disease,
      required this.recommendations,
      required this.importance});

  factory VaccineInfo.fromJson(Map<String, dynamic> json) {
    return VaccineInfo(
      disease: json['Vaccines for disease'] as String,
      recommendations: json['Recommendations'] as String,
      importance: json['importance'] as String,
    );
  }
}
