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
      final response = await http.get(url).timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Server is waking up from sleep. Please try again.');
    } catch (e) {
      throw Exception('No internet connection or network failure.');
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
      // 1. Attempt live network fetch with a 45s timeout for Render cold starts
      final response = await http.get(Uri.parse(urlString)).timeout(
            const Duration(seconds: 45),
          );

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
    } on TimeoutException {
      // 3. Fallback to cache on timeout (Render cold start)
      if (category != null && category.isNotEmpty) {
        final cachedData =
            await PlaceCacheService.getCachedNearbyPlaces(category: category);
        if (cachedData.isNotEmpty) return cachedData;
      }
      throw Exception('Server is waking up. Please try again in a moment.');
    } catch (e) {
      // 4. Fallback to cache if network fails entirely
      if (category != null && category.isNotEmpty) {
        final cachedData =
            await PlaceCacheService.getCachedNearbyPlaces(category: category);
        if (cachedData.isNotEmpty) {
          return cachedData;
        }
      }
      throw Exception('No internet connection and no cached data available.');
    }
  }
}
