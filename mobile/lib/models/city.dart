class City {
  const City({required this.id, required this.name});

  final int id;
  final String name;

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}
