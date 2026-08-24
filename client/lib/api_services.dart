import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<List<dynamic>> getPlacesByCategory(
    String category,
  ) async {
    final url = Uri.parse(
      '$baseUrl/places?category=${Uri.encodeComponent(category)}',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to load places: ${response.statusCode}',
      );
    }
  }

  static Future<List<dynamic>> getNearbyPlaces({
    required double lat,
    required double lng,
    int maxDistance = 20000,
    int limit = 10,
    String? category,
  }) async {
    String urlString =
        '$baseUrl/places/nearby?lat=$lat&lng=$lng&maxDistance=$maxDistance&limit=$limit';

    if (category != null && category.isNotEmpty) {
      urlString += '&category=${Uri.encodeComponent(category)}';
    }

    final response = await http.get(Uri.parse(urlString));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load nearby places');
    }
  }
}
