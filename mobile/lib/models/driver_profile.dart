import 'auth_session.dart';

class DriverProfile {
  const DriverProfile({
    required this.session,
    required this.licenseNumber,
    required this.isVerified,
    required this.cancellationStrikes,
    required this.cars,
    required this.cityIds,
  });

  final AuthSession session;
  final String licenseNumber;
  final bool isVerified;
  final int cancellationStrikes;
  final List<Map<String, dynamic>> cars;
  final List<int> cityIds;

  factory DriverProfile.fromJson(Map<String, dynamic> json) {
    final driver = json['driver'] as Map<String, dynamic>;
    final cars = (json['cars'] as List<dynamic>)
        .map((car) => Map<String, dynamic>.from(car as Map))
        .toList(growable: false);
    final cityIds = (json['cityIds'] as List<dynamic>).cast<int>();

    return DriverProfile(
      session: AuthSession(
        token: '',
        userId: driver['id'] as String,
        role: 'driver',
        fullName: driver['full_name'] as String,
        phoneNumber: driver['phone_number'] as String,
        surname: driver['surname'] as String,
      ),
      licenseNumber: driver['license_number'] as String,
      isVerified: driver['is_verified'] as bool,
      cancellationStrikes: driver['cancellation_strikes'] as int,
      cars: cars,
      cityIds: cityIds,
    );
  }
}
