import 'package:flutter/material.dart';
import 'theme.dart';
import '../favorites_services.dart';
import 'place_details.dart';
import 'formatters.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Map<String, dynamic>> favorites = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final savedFavorites = await FavoritesService.getFavorites();

    if (!mounted) return;

    setState(() {
      favorites = savedFavorites;
      isLoading = false;
    });
  }

  Future<void> _removeFavorite(Map<String, dynamic> place) async {
    await FavoritesService.removeFavorite(place);

    if (!mounted) return;

    setState(() {
      favorites.removeWhere(
        (favorite) =>
            (favorite['_id']?.toString() ?? favorite['osm_id']?.toString()) ==
            (place['_id']?.toString() ?? place['osm_id']?.toString()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.horizontal(context),
            vertical: AppSpacing.vertical(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: AppColors.darkText,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Favorites',
                        style: AppTextStyles.pageTitle(context),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.bookmark_rounded,
                        color: AppColors.primaryTeal,
                        size: 22,
                      ),
                      Text(
                        'Bookmarked',
                        style: AppTextStyles.categorySubtitle(context).copyWith(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : favorites.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.bookmark_border_rounded,
                                  size: 64,
                                  color: AppColors.primaryTeal.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No favorites yet',
                                  style: AppTextStyles.categoryTitle(context),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Save places you like to find them easily later.',
                                  textAlign: TextAlign.center,
                                  style:
                                      AppTextStyles.categorySubtitle(context),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: favorites.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final place = favorites[index];

                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PlaceDetails(
                                        place: Map<String, dynamic>.from(place),
                                      ),
                                    ),
                                  ).then((_) => _loadFavorites());
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardBgColor,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              formatDisplayText(
                                                place['name'].toString(),
                                              ),
                                              style:
                                                  AppTextStyles.categoryTitle(
                                                context,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            if (place['description'] != null)
                                              Text(
                                                place['description'].toString(),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: AppTextStyles
                                                    .categorySubtitle(context),
                                              ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      IconButton(
                                        onPressed: () => _removeFavorite(place),
                                        icon: const Icon(
                                          Icons.bookmark_rounded,
                                        ),
                                        color: AppColors.primaryTeal,
                                        tooltip: 'Remove from favorites',
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
