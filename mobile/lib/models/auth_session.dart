class AuthSession {
  const AuthSession({
    required this.token,
    required this.userId,
    required this.role,
    required this.fullName,
    required this.phoneNumber,
    this.surname,
  });

  final String token;
  final String userId;
  final String role;
  final String fullName;
  final String phoneNumber;
  final String? surname;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;

    return AuthSession(
      token: json['token'] as String,
      userId: user['id'] as String,
      role: user['role'] as String,
      fullName: user['fullName'] as String,
      phoneNumber: user['phoneNumber'] as String,
      surname: user['surname'] as String?,
    );
  }
}
