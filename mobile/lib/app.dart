import 'package:flutter/material.dart';

import 'screens/auth_gate.dart';
import 'theme/app_theme.dart';

class IraqRideApp extends StatelessWidget {
  const IraqRideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Iraq Ride',
      theme: buildAppTheme(),
      home: const AuthGate(),
    );
  }
}
