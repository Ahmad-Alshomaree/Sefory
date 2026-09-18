import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  static const String baseUrl = 'http://10.0.2.2:4000';
  final http.Client _client;

  Future<Map<String, dynamic>> get(String path, {String? token}) async {
    final response = await _client.get(
      Uri.parse('$baseUrl$path'),
      headers: _headers(token),
    );

    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body, {String? token}) async {
    final response = await _client.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers(token),
      body: jsonEncode(body),
    );

    return _decodeResponse(response);
  }

  Map<String, String> _headers(String? token) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 400) {
      final message = decoded['error'] is Map<String, dynamic>
          ? decoded['error']['message'] as String? ?? 'Request failed'
          : 'Request failed';
      throw ApiException(message);
    }

    return decoded;
  }
}

class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
