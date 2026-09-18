import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import '../models/city.dart';
import '../network/api_client.dart';

class TripRequestScreen extends StatefulWidget {
  const TripRequestScreen({super.key, required this.session});

  final AuthSession session;

  @override
  State<TripRequestScreen> createState() => _TripRequestScreenState();
}

class _TripRequestScreenState extends State<TripRequestScreen> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();
  late Future<List<City>> _citiesFuture;
  City? _departureCity;
  City? _destinationCity;
  String _tripType = 'family';
  bool _isSubmitting = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _citiesFuture = _loadCities();
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }

  Future<List<City>> _loadCities() async {
    final response = await _apiClient.get('/api/v1/cities');
    final cities = response['data'] as List<dynamic>;
    return cities
        .map((city) => City.fromJson(city as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<void> _submitTrip() async {
    if (_departureCity == null || _destinationCity == null) {
      setState(() {
        _message = 'Please select a departure and destination city.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _message = null;
    });

    try {
      await _apiClient.post(
        '/api/v1/trips',
        {
          'passengerId': widget.session.userId,
          'tripType': _tripType,
          'departureCityId': _departureCity!.id,
          'destinationCityId': _destinationCity!.id,
          'pickupMapLink': _pickupController.text.trim(),
          'dropoffMapLink': _dropoffController.text.trim(),
        },
        token: widget.session.token,
      );

      setState(() {
        _message = 'Trip request submitted successfully.';
      });
    } on ApiException catch (error) {
      setState(() {
        _message = error.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
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
              'Request a trip, ${widget.session.fullName}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            const Text('Paste Google Maps links for pickup and drop-off.'),
            const SizedBox(height: 20),
            _DropdownCard<City>(
              label: 'Departure city',
              value: _departureCity,
              items: cities,
              itemLabel: (city) => city.name,
              onChanged: (city) => setState(() => _departureCity = city),
            ),
            const SizedBox(height: 12),
            _DropdownCard<City>(
              label: 'Destination city',
              value: _destinationCity,
              items: cities,
              itemLabel: (city) => city.name,
              onChanged: (city) => setState(() => _destinationCity = city),
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
            const SizedBox(height: 12),
            _InputCard(
              controller: _pickupController,
              label: 'Pickup location link',
              hint: 'https://maps.google.com/...',
            ),
            const SizedBox(height: 12),
            _InputCard(
              controller: _dropoffController,
              label: 'Drop-off location link',
              hint: 'https://maps.google.com/...',
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _isSubmitting ? null : _submitTrip,
              child: Text(_isSubmitting ? 'Submitting...' : 'Request trip'),
            ),
            if (_message != null) ...[
              const SizedBox(height: 12),
              Text(_message!),
            ],
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

class _InputCard extends StatelessWidget {
  const _InputCard({required this.controller, required this.label, required this.hint});

  final TextEditingController controller;
  final String label;
  final String hint;

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
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
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
