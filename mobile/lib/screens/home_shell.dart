import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import 'driver_home_screen.dart';
import 'driver_profile_screen.dart';
import 'passenger_home_screen.dart';
import 'trip_request_screen.dart';
import 'trip_status_screen.dart';
import 'trip_history_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.session, required this.onLogout});

  final AuthSession session;
  final VoidCallback onLogout;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int selectedIndex = 0;
  bool isDriverMode = false;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = isDriverMode
        ? [
            const DriverHomeScreen(),
            const TripStatusScreen(),
            DriverProfileScreen(session: widget.session),
            TripHistoryScreen(session: widget.session),
          ]
        : [
            PassengerHomeScreen(session: widget.session),
            TripRequestScreen(session: widget.session),
            const TripStatusScreen(),
            TripHistoryScreen(session: widget.session),
          ];

    final destinations = isDriverMode
        ? const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Requests',
            ),
            NavigationDestination(
              icon: Icon(Icons.local_taxi_outlined),
              selectedIcon: Icon(Icons.local_taxi),
              label: 'Trip',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'History',
            ),
          ]
        : const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(Icons.edit_location_alt_outlined),
              selectedIcon: Icon(Icons.edit_location_alt),
              label: 'Request',
            ),
            NavigationDestination(
              icon: Icon(Icons.local_taxi_outlined),
              selectedIcon: Icon(Icons.local_taxi),
              label: 'Status',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'History',
            ),
          ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Iraq Ride · ${widget.session.fullName}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: widget.onLogout,
              child: const Text('Logout'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            isDriverMode = !isDriverMode;
            selectedIndex = 0;
          });
        },
        icon: Icon(isDriverMode ? Icons.badge_outlined : Icons.person_outline),
        label: Text(isDriverMode ? 'Driver mode' : 'Passenger mode'),
      ),
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: destinations,
      ),
    );
  }
}
