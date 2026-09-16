import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_places';

  static Future<void> addFavorite(
    Map<String, dynamic> place,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final favorites = await getFavorites();

    final placeId = place['_id']?.toString() ?? place['osm_id']?.toString();

    final alreadyExists = favorites.any(
      (favorite) {
        final favoriteId =
            favorite['_id']?.toString() ?? favorite['osm_id']?.toString();

        return favoriteId == placeId;
      },
    );

    if (!alreadyExists) {
      favorites.add(place);

      await prefs.setString(
        _favoritesKey,
        jsonEncode(favorites),
      );
    }
  }

  static Future<void> removeFavorite(
    Map<String, dynamic> place,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final favorites = await getFavorites();

    final placeId = place['_id']?.toString() ?? place['osm_id']?.toString();

    favorites.removeWhere(
      (favorite) {
        final favoriteId =
            favorite['_id']?.toString() ?? favorite['osm_id']?.toString();

        return favoriteId == placeId;
      },
    );

    await prefs.setString(
      _favoritesKey,
      jsonEncode(favorites),
    );
  }

  static Future<List<Map<String, dynamic>>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = prefs.getString(_favoritesKey);

    if (jsonString == null) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(jsonString);

    return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  static Future<bool> isFavorite(
    Map<String, dynamic> place,
  ) async {
    final favorites = await getFavorites();

    final placeId = place['_id']?.toString() ?? place['osm_id']?.toString();

    return favorites.any(
      (favorite) {
        final favoriteId =
            favorite['_id']?.toString() ?? favorite['osm_id']?.toString();

        return favoriteId == placeId;
      },
    );
  }
}
