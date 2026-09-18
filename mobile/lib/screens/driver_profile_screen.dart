import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import '../network/api_client.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key, required this.session});

  final AuthSession session;

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _cityIdsController = TextEditingController();

  late Future<Map<String, dynamic>> _profileFuture;
  String? _message;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  @override
  void dispose() {
    _modelController.dispose();
    _nameController.dispose();
    _plateController.dispose();
    _colorController.dispose();
    _yearController.dispose();
    _priceController.dispose();
    _cityIdsController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _loadProfile() async {
    final response = await _apiClient.get('/api/v1/drivers/me', token: widget.session.token);
    return response['data'] as Map<String, dynamic>;
  }

  Future<void> _saveCar() async {
    setState(() {
      _message = null;
    });

    await _apiClient.post(
      '/api/v1/drivers/me/cars',
      {
        'model': _modelController.text.trim(),
        'name': _nameController.text.trim(),
        'plateNumber': _plateController.text.trim(),
        'color': _colorController.text.trim(),
        'year': int.tryParse(_yearController.text.trim()),
        'price': double.tryParse(_priceController.text.trim()),
      },
      token: widget.session.token,
    );

    setState(() {
      _message = 'Car saved successfully.';
      _profileFuture = _loadProfile();
    });
  }

  Future<void> _saveCities() async {
    final cityIds = _cityIdsController.text
        .split(',')
        .map((value) => int.tryParse(value.trim()))
        .whereType<int>()
        .toList(growable: false);

    if (cityIds.isEmpty) {
      setState(() {
        _message = 'Enter at least one city ID.';
      });
      return;
    }

    await _apiClient.post(
      '/api/v1/drivers/me/cities',
      {
        'cityIds': cityIds,
      },
      token: widget.session.token,
    );

    setState(() {
      _message = 'Allowed cities updated successfully.';
      _profileFuture = _loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Unable to load driver profile: ${snapshot.error}'));
        }

        final data = snapshot.data ?? <String, dynamic>{};
        final driver = data['driver'] as Map<String, dynamic>;
        final cars = (data['cars'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();
        final cityIds = (data['cityIds'] as List<dynamic>? ?? const []).cast<int>();

        if (_cityIdsController.text.isEmpty && cityIds.isNotEmpty) {
          _cityIdsController.text = cityIds.join(', ');
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Driver profile, ${widget.session.fullName}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text('License: ${driver['license_number']}'),
            const SizedBox(height: 12),
            Text('Verified: ${driver['is_verified'] ? 'Yes' : 'No'}'),
            const SizedBox(height: 12),
            Text('Cancellation strikes: ${driver['cancellation_strikes']}'),
            const SizedBox(height: 20),
            const Text('Add car', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _Field(controller: _modelController, label: 'Model', hint: 'Toyota Camry'),
            const SizedBox(height: 12),
            _Field(controller: _nameController, label: 'Name', hint: 'Camry VIP'),
            const SizedBox(height: 12),
            _Field(controller: _plateController, label: 'Plate number', hint: '12345'),
            const SizedBox(height: 12),
            _Field(controller: _colorController, label: 'Color', hint: 'White'),
            const SizedBox(height: 12),
            _Field(controller: _yearController, label: 'Year', hint: '2020', keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _Field(controller: _priceController, label: 'Base price', hint: '35000', keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _saveCar,
              child: const Text('Save car'),
            ),
            const SizedBox(height: 20),
            const Text('Cars', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...cars.map(
              (car) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: ListTile(
                    title: Text('${car['model']} · ${car['plate_number']}'),
                    subtitle: Text('Name: ${car['name'] ?? 'N/A'} · Price: ${car['price'] ?? 'N/A'}'),
                  ),
                ),
              ),
            ),
            if (cars.isEmpty) const Text('No cars registered yet.'),
            const SizedBox(height: 20),
            const Text('Allowed city IDs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _Field(
              controller: _cityIdsController,
              label: 'City IDs',
              hint: '1, 2, 5',
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _saveCities,
              child: const Text('Save allowed cities'),
            ),
            const SizedBox(height: 12),
            Text(cityIds.isEmpty ? 'No cities configured yet.' : 'Current city IDs: ${cityIds.join(', ')}'),
            if (_message != null) ...[
              const SizedBox(height: 12),
              Text(_message!),
            ],
          ],
        );
      },
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
