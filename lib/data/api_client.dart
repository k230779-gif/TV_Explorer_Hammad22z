import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

// A readable error that the blocs pass to the UI
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

// Shared HTTP layer; each feature's API file builds on it
class ApiClient {
  static const String _baseUrl = 'https://api.tvmaze.com';
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<dynamic> get(String path, {bool allowNotFound = false}) async {
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl$path'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) return jsonDecode(response.body);
      if (response.statusCode == 404 && allowNotFound) return null;
      if (response.statusCode == 429) {
        throw const ApiException(
            'Too many requests. Please wait a moment and try again.');
      }
      throw ApiException(
          'Server error (${response.statusCode}). Please try again.');
    } on SocketException {
      throw const ApiException('No internet connection.');
    } on http.ClientException {
      throw const ApiException('No internet connection.');
    } on TimeoutException {
      throw const ApiException('The request timed out. Please try again.');
    } on FormatException {
      throw const ApiException('Received invalid data from the server.');
    }
  }
}