class DriverSearchResult {
  const DriverSearchResult({
    required this.driverId,
    required this.fullName,
    required this.surname,
    required this.phoneNumber,
    required this.isVerified,
    required this.cancellationStrikes,
    required this.carId,
    required this.model,
    required this.plateNumber,
    required this.price,
    this.carName,
    this.color,
    this.year,
    this.photoUrl,
  });

  final String driverId;
  final String fullName;
  final String surname;
  final String phoneNumber;
  final bool isVerified;
  final int cancellationStrikes;
  final String carId;
  final String model;
  final String plateNumber;
  final String? price;
  final String? carName;
  final String? color;
  final int? year;
  final String? photoUrl;

  factory DriverSearchResult.fromJson(Map<String, dynamic> json) {
    return DriverSearchResult(
      driverId: json['driverId'] as String,
      fullName: json['fullName'] as String,
      surname: json['surname'] as String,
      phoneNumber: json['phoneNumber'] as String,
      isVerified: json['isVerified'] as bool,
      cancellationStrikes: json['cancellationStrikes'] as int,
      carId: json['carId'] as String,
      model: json['model'] as String,
      plateNumber: json['plateNumber'] as String,
      price: json['price'] as String?,
      carName: json['name'] as String?,
      color: json['color'] as String?,
      year: json['year'] as int?,
      photoUrl: json['photoUrl'] as String?,
    );
  }
}
