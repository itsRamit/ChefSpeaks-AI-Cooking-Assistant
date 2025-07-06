import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class ApiService {
  final http.Client _client = http.Client();

  Future<dynamic> post({
    required String baseUrl,
    required String path,
    Map<String, dynamic>? body,
    bool isHttps = false,
  }) async {
    final uri = isHttps
        ? Uri.https(baseUrl, path)
        : Uri.http(baseUrl, path);

    try {
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      log("POST ${uri.toString()}");
      log("Status: ${response.statusCode}");
      log("Body: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw Exception("Error: ${response.statusCode} ${response.reasonPhrase}");
      }
    } catch (e) {
      log("POST Error: $e");
      throw Exception("POST request failed: $e");
    }
  }

  Future<dynamic> get({
    required String baseUrl,
    required String path,
    Map<String, String>? queryParams,
    bool isHttps = false,
  }) async {
    final uri = isHttps
        ? Uri.https(baseUrl, path, queryParams)
        : Uri.http(baseUrl, path, queryParams);

    try {
      final response = await _client.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      );

      log("GET ${uri.toString()}");
      log("Status: ${response.statusCode}");
      log("Body: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw Exception("Error: ${response.statusCode} ${response.reasonPhrase}");
      }
    } catch (e) {
      log("GET Error: $e");
      throw Exception("GET request failed: $e");
    }
  }
}

