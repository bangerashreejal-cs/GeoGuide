import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'theme.dart';
import '../api_services.dart';
import 'place_details.dart';
import 'formatters.dart';

class ResultScreen extends StatefulWidget {
  final String category;
  final String apiCategory;

  const ResultScreen({
    super.key,
    required this.category,
    required this.apiCategory,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  List<dynamic> places = [];
  bool isLoading = true;
  bool isRefreshing = false;

  // Filter state variables
  int selectedDistance = 1000; // in meters
  int selectedLimit = 1; // Show places

  @override
  void initState() {
    super.initState();
    _fetchNearbyPlaces();
  }

  // Helper method to fetch the current device position safely
  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null; // Location services disabled
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null; // Permissions denied
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null; // Permissions permanently denied
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _fetchNearbyPlaces() async {
    setState(() => isLoading = true);

    try {
      // 1. Get live GPS position
      Position? position = await _determinePosition();

      // 2. Fallback coordinates if location fails or is denied
      double lat = position?.latitude ?? 19.0416956;
      double lng = position?.longitude ?? 73.0362166;

      print("Fetching places for Lat: $lat, Lng: $lng");

      final data = await ApiService.getNearbyPlaces(
        lat: lat,
        lng: lng,
        maxDistance: selectedDistance,
        limit: selectedLimit,
        category: widget.apiCategory,
      );

      setState(() {
        places = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading nearby places: $e');

      setState(() {
        isLoading = false;
      });
    }
  }

  // Refreshes the phone's current location and nearby places
  Future<void> _refreshLocation() async {
    if (isRefreshing) return;

    setState(() {
      isRefreshing = true;
    });

    try {
      await _fetchNearbyPlaces();
    } finally {
      if (mounted) {
        setState(() {
          isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = AppSpacing.isPhone(context);

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
              // ============================
              // HEADER
              // ============================
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                    ),
                    color: AppColors.darkText,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.category,
                        style: AppTextStyles.pageTitle(context),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: isPhone ? 24 : 40,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ============================
              // FILTER DROPDOWNS
              // ============================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Distance Dropdown
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: selectedDistance,
                          isExpanded: true,
                          style: AppTextStyles.categorySubtitle(context),
                          items: const [
                            DropdownMenuItem(
                              value: 1000,
                              child: Text('Within 1 km'),
                            ),
                            DropdownMenuItem(
                              value: 5000,
                              child: Text('Within 5 km'),
                            ),
                            DropdownMenuItem(
                              value: 10000,
                              child: Text('Within 10 km'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                selectedDistance = val;
                              });

                              _fetchNearbyPlaces();
                            }
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Limit Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: selectedLimit,
                        style: AppTextStyles.categorySubtitle(context),
                        items: const [
                          DropdownMenuItem(
                            value: 1,
                            child: Text('Show 1'),
                          ),
                          DropdownMenuItem(
                            value: 3,
                            child: Text('Show 3'),
                          ),
                          DropdownMenuItem(
                            value: 5,
                            child: Text('Show 5'),
                          ),
                          DropdownMenuItem(
                            value: 10,
                            child: Text('Show 10'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              selectedLimit = val;
                            });

                            _fetchNearbyPlaces();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ============================
              // RESULTS COUNT + REFRESH
              // ============================
              if (!isLoading)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${places.length} places found nearby',
                      style: AppTextStyles.categorySubtitle(context),
                    ),
                    IconButton(
                      onPressed: isRefreshing ? null : _refreshLocation,
                      icon: isRefreshing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.refresh_rounded,
                            ),
                      color: AppColors.primaryTeal,
                      tooltip: 'Refresh location',
                    ),
                  ],
                ),

              const SizedBox(height: 16),

              // ============================
              // PLACES LIST
              // ============================
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : places.isEmpty
                        ? Center(
                            child: Text(
                              'No places found nearby for this category.',
                              style: AppTextStyles.categorySubtitle(
                                context,
                              ),
                            ),
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: places.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final place = places[index];

                              // Safely parse distance_km
                              final double? distanceKm =
                                  place['distance_km'] != null
                                      ? (place['distance_km'] as num).toDouble()
                                      : null;

                              // ============================
                              // CLICKABLE PLACE CARD
                              // ============================
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PlaceDetails(
                                        place: Map<String, dynamic>.from(
                                          place,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardBgColor,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // NAME + DISTANCE
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              formatDisplayText(
                                                place['name'].toString(),
                                              ),
                                              style:
                                                  AppTextStyles.categoryTitle(
                                                context,
                                              ),
                                            ),
                                          ),
                                          if (distanceKm != null)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.green
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                distanceKm < 1.0
                                                    ? '${(distanceKm * 1000).toStringAsFixed(0)} m'
                                                    : '${distanceKm.toStringAsFixed(2)} km',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),

                                      const SizedBox(height: 6),

                                      // DESCRIPTION
                                      if (place['description'] != null)
                                        Text(
                                          place['description'].toString(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.categorySubtitle(
                                            context,
                                          ),
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
