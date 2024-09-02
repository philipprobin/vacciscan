class Vaccination {
  final String brand;
  final String against;
  final String date;

  Vaccination(this.brand, this.against, this.date);

  factory Vaccination.fromJson(Map<String, dynamic> json) {
    return Vaccination(
      json['brand'],
      json['against'],
      json['date'],
    );
  }

  Map<String, dynamic> toJson() => {
    'brand': brand,
    'against': against,
    'date': date,
  };
}
