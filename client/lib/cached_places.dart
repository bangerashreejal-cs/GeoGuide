// lib/services/place_cache_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PlaceCacheService {
  // Save nearby places list and timestamp scoped by category
  static Future<void> saveNearbyPlaces(
    List<Map<String, dynamic>> places, {
    required String category,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(places);

    await prefs.setString('cached_nearby_places_$category', jsonString);
    await prefs.setInt(
        'cache_timestamp_$category', DateTime.now().millisecondsSinceEpoch);
  }

  // Retrieve cached nearby places scoped by category
  static Future<List<Map<String, dynamic>>> getCachedNearbyPlaces({
    required String category,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('cached_nearby_places_$category');

    if (jsonString == null) return [];

    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  // Check if cache is older than 24 hours for a specific category
  static Future<bool> isCacheExpired({
    required String category,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('cache_timestamp_$category');
    if (timestamp == null) return true;

    final savedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime.now().difference(savedTime).inHours > 24;
  }
}
