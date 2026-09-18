import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import '../network/api_client.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.onAuthenticated});

  final ValueChanged<AuthSession> onAuthenticated;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _licenseNumberController = TextEditingController();

  bool _isDriver = false;
  bool _isRegister = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _fullNameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final path = _buildPath();
      final payload = _buildPayload();
      final response = await _apiClient.post(path, payload);
      final session = AuthSession.fromJson(response['data'] as Map<String, dynamic>);
      widget.onAuthenticated(session);
    } on ApiException catch (error) {
      setState(() {
        _errorMessage = error.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _buildPath() {
    if (_isDriver) {
      return _isRegister ? '/api/v1/auth/drivers/register' : '/api/v1/auth/drivers/login';
    }
    return _isRegister ? '/api/v1/auth/passengers/register' : '/api/v1/auth/passengers/login';
  }

  Map<String, dynamic> _buildPayload() {
    final payload = <String, dynamic>{
      'phoneNumber': _phoneController.text.trim(),
      'password': _passwordController.text,
    };

    if (_isRegister) {
      payload['fullName'] = _fullNameController.text.trim();
    }

    if (_isDriver) {
      if (_isRegister) {
        payload['surname'] = _surnameController.text.trim();
        payload['licenseNumber'] = _licenseNumberController.text.trim();
      }
    }

    return payload;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 24),
            const Text(
              'Iraq Ride',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text('Passenger and driver access for the intercity booking flow.'),
            const SizedBox(height: 24),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(value: false, label: Text('Passenger')),
                ButtonSegment<bool>(value: true, label: Text('Driver')),
              ],
              selected: <bool>{_isDriver},
              onSelectionChanged: (selection) {
                setState(() {
                  _isDriver = selection.first;
                });
              },
            ),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(value: true, label: Text('Register')),
                ButtonSegment<bool>(value: false, label: Text('Login')),
              ],
              selected: <bool>{_isRegister},
              onSelectionChanged: (selection) {
                setState(() {
                  _isRegister = selection.first;
                });
              },
            ),
            const SizedBox(height: 20),
            if (_isRegister)
              _InputField(
                controller: _fullNameController,
                label: 'Full name',
                hint: 'Enter your full name',
              ),
            if (_isRegister) const SizedBox(height: 12),
            if (_isDriver && _isRegister)
              _InputField(
                controller: _surnameController,
                label: 'Surname',
                hint: 'Enter your surname',
              ),
            if (_isDriver && _isRegister) const SizedBox(height: 12),
            _InputField(
              controller: _phoneController,
              label: 'Phone number',
              hint: '07xxxxxxxxx',
            ),
            const SizedBox(height: 12),
            _InputField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Create a password',
              obscureText: true,
            ),
            if (_isDriver && _isRegister) const SizedBox(height: 12),
            if (_isDriver && _isRegister)
              _InputField(
                controller: _licenseNumberController,
                label: 'License number',
                hint: 'Driver license number',
              ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _isLoading ? null : _submit,
              child: Text(_isLoading ? 'Please wait...' : (_isRegister ? 'Create account' : 'Sign in')),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
