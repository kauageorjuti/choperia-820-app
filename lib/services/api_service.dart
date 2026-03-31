import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  ApiService({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Future<dynamic> get(String endpoint) async {
    final response = await _client.get(Uri.parse('$baseUrl$endpoint'));
    return _decodeResponse(response);
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final response = await _client.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _decodeResponse(response);
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final response = await _client.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _decodeResponse(response);
  }

  Future<dynamic> delete(String endpoint) async {
    final response = await _client.delete(Uri.parse('$baseUrl$endpoint'));
    return _decodeResponse(response);
  }

  dynamic _decodeResponse(http.Response response) {
    final decodedBody =
        response.body.isNotEmpty ? jsonDecode(response.body) : null;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decodedBody;
    }
    throw Exception('Erro ${response.statusCode}: ${response.body}');
  }
}
