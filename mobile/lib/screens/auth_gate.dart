import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import 'auth_screen.dart';
import 'home_shell.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  AuthSession? _session;

  @override
  Widget build(BuildContext context) {
    if (_session == null) {
      return AuthScreen(
        onAuthenticated: (session) {
          setState(() {
            _session = session;
          });
        },
      );
    }

    return HomeShell(
      session: _session!,
      onLogout: () {
        setState(() {
          _session = null;
        });
      },
    );
  }
}
