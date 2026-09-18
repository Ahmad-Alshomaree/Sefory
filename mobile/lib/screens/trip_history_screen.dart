import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import '../models/trip_record.dart';
import '../network/api_client.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key, required this.session});

  final AuthSession session;

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  final ApiClient _apiClient = ApiClient();
  late Future<List<TripRecord>> _tripsFuture;

  @override
  void initState() {
    super.initState();
    _tripsFuture = _loadTrips();
  }

  Future<List<TripRecord>> _loadTrips() async {
    final response = await _apiClient.get('/api/v1/trips', token: widget.session.token);
    final trips = response['data'] as List<dynamic>;
    return trips
        .map((trip) => TripRecord.fromJson(trip as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TripRecord>>(
      future: _tripsFuture,
      builder: (context, snapshot) {
        final trips = snapshot.data ?? <TripRecord>[];

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Trip history for ${widget.session.fullName}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            const Text('Past trips are loaded from the backend.'),
            const SizedBox(height: 20),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
            ...trips.map(
              (trip) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.directions_car_outlined),
                    title: Text('Trip ${trip.id.substring(0, 8)}'),
                    subtitle: Text('Status: ${trip.status} · ${trip.tripType} · ${trip.requestedAt}'),
                    trailing: TextButton(
                      onPressed: () {},
                      child: const Text('Book again'),
                    ),
                  ),
                ),
              ),
            ),
            if (trips.isEmpty && snapshot.connectionState == ConnectionState.done)
              const Text('No trips yet.'),
            if (snapshot.hasError) ...[
              const SizedBox(height: 12),
              Text('Unable to load trips: ${snapshot.error}'),
            ],
          ],
        );
      },
    );
  }
}
