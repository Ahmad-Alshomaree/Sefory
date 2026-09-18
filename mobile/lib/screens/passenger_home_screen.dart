import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import '../models/city.dart';
import '../models/driver_search_result.dart';
import '../network/api_client.dart';

class PassengerHomeScreen extends StatefulWidget {
  const PassengerHomeScreen({super.key, required this.session});

  final AuthSession session;

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  final ApiClient _apiClient = ApiClient();
  late Future<List<City>> _citiesFuture;
  Future<List<DriverSearchResult>>? _searchFuture;
  City? _departureCity;
  City? _destinationCity;
  String _tripType = 'family';

  @override
  void initState() {
    super.initState();
    _citiesFuture = _loadCities();
  }

  Future<List<City>> _loadCities() async {
    final response = await _apiClient.get('/api/v1/cities');
    final cities = response['data'] as List<dynamic>;
    return cities
        .map((city) => City.fromJson(city as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<List<DriverSearchResult>> _searchDrivers() async {
    final response = await _apiClient.get(
      '/api/v1/drivers/search?departureCityId=${_departureCity!.id}&destinationCityId=${_destinationCity!.id}',
      token: widget.session.token,
    );
    final drivers = response['data'] as List<dynamic>;
    return drivers
        .map((driver) => DriverSearchResult.fromJson(driver as Map<String, dynamic>))
        .toList(growable: false);
  }

  void _runSearch() {
    if (_departureCity == null || _destinationCity == null) {
      setState(() {
        _searchFuture = Future.error('Please select a departure and destination city.');
      });
      return;
    }

    setState(() {
      _searchFuture = _searchDrivers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<City>>(
      future: _citiesFuture,
      builder: (context, snapshot) {
        final cities = snapshot.data ?? <City>[];

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Find a trip, ${widget.session.fullName}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            const Text('Search by city, route, and trip type.'),
            const SizedBox(height: 20),
            _DropdownCard<City>(
              label: 'Departure city',
              value: _departureCity,
              items: cities,
              itemLabel: (city) => city.name,
              onChanged: (city) {
                setState(() {
                  _departureCity = city;
                });
              },
            ),
            const SizedBox(height: 12),
            _DropdownCard<City>(
              label: 'Destination city',
              value: _destinationCity,
              items: cities,
              itemLabel: (city) => city.name,
              onChanged: (city) {
                setState(() {
                  _destinationCity = city;
                });
              },
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Trip type', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment<String>(value: 'family', label: Text('Family')),
                        ButtonSegment<String>(value: 'individual', label: Text('Individual')),
                      ],
                      selected: <String>{_tripType},
                      onSelectionChanged: (selection) {
                        setState(() {
                          _tripType = selection.first;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _runSearch,
              icon: const Icon(Icons.search),
              label: const Text('Search cars'),
            ),
            const SizedBox(height: 24),
            if (_searchFuture != null)
              FutureBuilder<List<DriverSearchResult>>(
                future: _searchFuture,
                builder: (context, searchSnapshot) {
                  if (searchSnapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (searchSnapshot.hasError) {
                    return Text('Search failed: ${searchSnapshot.error}');
                  }

                  final results = searchSnapshot.data ?? <DriverSearchResult>[];

                  if (results.isEmpty) {
                    return const Text('No drivers matched this route yet.');
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Available drivers',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      ...results.map(
                        (result) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(result.fullName.isNotEmpty ? result.fullName[0] : '?'),
                              ),
                              title: Text('${result.fullName} ${result.surname}'),
                              subtitle: Text(
                                '${result.model} · ${result.plateNumber}\nPrice: ${result.price ?? 'TBD'} · ${result.isVerified ? 'Verified' : 'Unverified'}',
                              ),
                              isThreeLine: true,
                              trailing: TextButton(
                                onPressed: () {},
                                child: const Text('Request'),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            const SizedBox(height: 24),
            const Text(
              'Implementation status',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const _StatusCard(
              title: 'Phase 1 core flow',
              subtitle: 'Passenger search, trip request, and status tracking are wired to the backend.',
            ),
            if (snapshot.hasError) ...[
              const SizedBox(height: 12),
              Text('Unable to load cities: ${snapshot.error}'),
            ],
          ],
        );
      },
    );
  }
}

class _DropdownCard<T> extends StatelessWidget {
  const _DropdownCard({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            DropdownButtonFormField<T>(
              initialValue: value,
              items: items
                  .map(
                    (item) => DropdownMenuItem<T>(
                      value: item,
                      child: Text(itemLabel(item)),
                    ),
                  )
                  .toList(growable: false),
              onChanged: onChanged,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(subtitle),
          ],
        ),
      ),
    );
  }
}
