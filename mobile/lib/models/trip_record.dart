class TripRecord {
  const TripRecord({
    required this.id,
    required this.passengerId,
    required this.tripType,
    required this.departureCityId,
    required this.destinationCityId,
    required this.pickupMapLink,
    required this.dropoffMapLink,
    required this.status,
    required this.requestedAt,
    this.driverId,
    this.carId,
    this.price,
  });

  final String id;
  final String passengerId;
  final String? driverId;
  final String? carId;
  final String tripType;
  final int departureCityId;
  final int destinationCityId;
  final String pickupMapLink;
  final String dropoffMapLink;
  final String status;
  final String? price;
  final String requestedAt;

  factory TripRecord.fromJson(Map<String, dynamic> json) {
    return TripRecord(
      id: json['id'] as String,
      passengerId: json['passengerId'] as String,
      driverId: json['driverId'] as String?,
      carId: json['carId'] as String?,
      tripType: json['tripType'] as String,
      departureCityId: json['departureCityId'] as int,
      destinationCityId: json['destinationCityId'] as int,
      pickupMapLink: json['pickupMapLink'] as String,
      dropoffMapLink: json['dropoffMapLink'] as String,
      status: json['status'] as String,
      price: json['price'] as String?,
      requestedAt: json['requestedAt'] as String,
    );
  }
}
