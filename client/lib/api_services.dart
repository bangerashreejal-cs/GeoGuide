import 'dart:convert';
import 'package:http/http.dart' as http;
import 'cached_places.dart'; // Import your cache service

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
      // 1. Attempt live network fetch
      final response = await http.get(Uri.parse(urlString));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // 2. Save fetched data locally scoped by category
        final mapList = data.map((e) => Map<String, dynamic>.from(e)).toList();
        if (category != null && category.isNotEmpty) {
          await PlaceCacheService.saveNearbyPlaces(mapList, category: category);
        }

        return data;
      } else {
        throw Exception('Failed to load nearby places');
      }
    } catch (e) {
      // 3. Fallback: Return category-specific cached data if offline and not expired
      if (category != null && category.isNotEmpty) {
        final bool expired =
            await PlaceCacheService.isCacheExpired(category: category);

        if (!expired) {
          final cachedData =
              await PlaceCacheService.getCachedNearbyPlaces(category: category);
          if (cachedData.isNotEmpty) {
            return cachedData;
          }
        }
      }
      throw Exception('Network error and local cache expired or not found: $e');
    }
  }
}
