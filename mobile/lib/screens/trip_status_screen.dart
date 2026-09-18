import 'package:flutter/material.dart';

class TripStatusScreen extends StatelessWidget {
  const TripStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Trip status',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        const Text('Track the current trip lifecycle here.'),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Status: accepted', style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 12),
                LinearProgressIndicator(value: 0.5),
                SizedBox(height: 16),
                Text('Assigned driver: Ahmed Al-Hassan'),
                SizedBox(height: 4),
                Text('Route: Baghdad to Basra'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
