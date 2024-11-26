class Vaccination {
  final String brand;
  final String against;
  final String date;

  Vaccination({
    required this.brand,
    required this.against,
    required this.date,
  });

  factory Vaccination.fromJson(Map<String, dynamic> json) {
    return Vaccination(
      brand: json['brand'],
      against: json['against'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() => {
    'brand': brand,
    'against': against,
    'date': date,
  };
}
