import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:5000"; // For Android emulator

  // Create request
  static Future<Map<String, dynamic>> createRequest(
      String userId, List<String> items) async {
    final response = await http.post(
      Uri.parse("$baseUrl/requests"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "items": items.map((e) => {"name": e}).toList(),
      }),
    );
    return jsonDecode(response.body);
  }

  // Fetch requests
  static Future<List<dynamic>> fetchRequests(String role, {String? userId}) async {
    final url = Uri.parse(
        "$baseUrl/requests?role=$role${userId != null ? "&userId=$userId" : ""}");
    final response = await http.get(url);
    return jsonDecode(response.body);
  }

  // Confirm item
  static Future<Map<String, dynamic>> confirmItem(
      String requestId, String itemId, bool available) async {
    final response = await http.put(
      Uri.parse("$baseUrl/requests/confirm"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "requestId": requestId,
        "itemId": itemId,
        "available": available,
      }),
    );
    return jsonDecode(response.body);
  }
}
