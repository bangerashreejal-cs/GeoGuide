import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'cached_places.dart';

class ApiService {
  static const String baseUrl = 'https://geoguide-bmgl.onrender.com';

  static Future<List<dynamic>> getPlacesByCategory(
    String category,
  ) async {
    final url = Uri.parse(
      '$baseUrl/places?category=${Uri.encodeComponent(category)}',
    );

    try {
      final response = await http.get(url).timeout(
            const Duration(seconds: 45),
          );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception(
        'Server is waking up from sleep. Please try again.',
      );
    } catch (e) {
      throw Exception(
        'No internet connection or network failure.',
      );
    }
  }

  static Future<List<dynamic>> getNearbyPlaces({
    required double lat,
    required double lng,
    int maxDistance = 1000,
    int limit = 1,
    String? category,
  }) async {
    String urlString =
        '$baseUrl/places/nearby?lat=$lat&lng=$lng&maxDistance=$maxDistance&limit=$limit';

    if (category != null && category.isNotEmpty) {
      urlString += '&category=${Uri.encodeComponent(category)}';
    }

    try {
      // Give Render enough time to wake up from a cold start.
      final response = await http.get(Uri.parse(urlString)).timeout(
            const Duration(seconds: 45),
          );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Save fresh results to cache.
        if (category != null && category.isNotEmpty) {
          final mapList =
              data.map((e) => Map<String, dynamic>.from(e)).toList();

          await PlaceCacheService.saveNearbyPlaces(
            mapList,
            category: category,
          );
        }

        return data;
      } else {
        throw Exception(
          'Backend returned status code ${response.statusCode}',
        );
      }
    } on TimeoutException {
      // Render may be sleeping/unreachable.
      // ResultScreen will handle the fallback to cache.
      throw Exception(
        'Backend request timed out.',
      );
    } catch (e) {
      // Any backend/network failure is passed back to ResultScreen.
      // ResultScreen decides whether cached data should be displayed.
      throw Exception(
        'Backend request failed: $e',
      );
    }
  }
}
