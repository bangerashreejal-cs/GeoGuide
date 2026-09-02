import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'theme.dart';
import '../api_services.dart';
import '../cached_places.dart';
import 'place_details.dart';
import 'formatters.dart';
import 'loading_screen.dart';
import 'dart:io';

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
  bool isOffline = false;
  bool hasInternet = false; // Tracks if we are showing cached data

  // Filter state variables
  int selectedDistance = 1000; // in meters
  int selectedLimit = 1; // Show places

  StreamSubscription<ServiceStatus>? _serviceStatusStreamSubscription;

  @override
  void initState() {
    super.initState();
    _fetchNearbyPlaces();

    // Real-time listener for location services toggle
    _serviceStatusStreamSubscription =
        Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      if (status == ServiceStatus.disabled) {
        _showBottomWarning('Location services were turned off.');
        _loadFromCacheOrEmpty();
      }
    });
  }

  @override
  void dispose() {
    _serviceStatusStreamSubscription?.cancel();
    super.dispose();
  }

  // Helper method to fetch the current device position safely
  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        _showBottomWarning('Please turn on location.');
      }
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  Future<void> _fetchNearbyPlaces() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      // Quick internet check to bypass long buffering when offline
      hasInternet = true;
      try {
        final result = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 3));
        if (result.isEmpty || result[0].rawAddress.isEmpty) {
          hasInternet = false;
        }
      } catch (_) {
        hasInternet = false;
      }

      if (!hasInternet) {
        if (mounted) {
          _showBottomWarning('No internet connection.');
        }
        await _loadFromCacheOrEmpty();
        return;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          _showBottomWarning('Please turn on location.');
        }
        await _loadFromCacheOrEmpty();
        return;
      }

      Position? position = await _determinePosition();
      if (position == null) {
        await _loadFromCacheOrEmpty();
        return;
      }

      double lat = position.latitude;
      double lng = position.longitude;

      final data = await ApiService.getNearbyPlaces(
        lat: lat,
        lng: lng,
        maxDistance: selectedDistance,
        limit: selectedLimit,
        category: widget.apiCategory,
      ).timeout(const Duration(seconds: 10));

      await PlaceCacheService.saveNearbyPlaces(
        List<Map<String, dynamic>>.from(data),
        category: widget.apiCategory,
      );

      if (!mounted) return;
      setState(() {
        places = data.take(selectedLimit).toList();
        isLoading = false;
        isOffline = false;
      });
    } catch (e) {
      print('Error loading nearby places: $e');

      final errorStr = e.toString().toLowerCase();
      bool isNetworkError = errorStr.contains('socket') ||
          errorStr.contains('timeout') ||
          errorStr.contains('failed host') ||
          errorStr.contains('network') ||
          errorStr.contains('connection');

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (isNetworkError) {
        if (mounted) {
          _showBottomWarning('No internet connection.');
        }
      } else if (!serviceEnabled) {
        if (mounted) {
          _showBottomWarning('Please turn on location.');
        }
      }

      if (isNetworkError || !serviceEnabled) {
        await _loadFromCacheOrEmpty();
      } else {
        if (!mounted) return;
        setState(() {
          places = [];
          isLoading = false;
          isOffline = false;
        });
      }
    }
  }

  // Helper to handle cache fallback cleanly
  Future<void> _loadFromCacheOrEmpty() async {
    List<Map<String, dynamic>> cachedData = [];
    try {
      cachedData = await PlaceCacheService.getCachedNearbyPlaces(
        category: widget.apiCategory,
      );

      // Filter by your distance slider limit safely supporting alternate keys
      cachedData = cachedData.where((place) {
        final double distance =
            ((place['distance'] ?? place['dist']) as num?)?.toDouble() ?? 0.0;
        return distance <= selectedDistance;
      }).toList();
    } catch (cacheError) {
      print('Cache read error: $cacheError');
    }

    if (!mounted) return;

    setState(() {
      places = cachedData.take(selectedLimit).toList();
      isLoading = false;
      isOffline =
          places.isNotEmpty; // Ensures banner activates when cache exists
    });
  }

  void _showBottomWarning(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primaryTeal,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _refreshLocation() async {
    if (isRefreshing) return;
    setState(() => isRefreshing = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          _showBottomWarning('Please turn on location.');
        }
      }
      await _fetchNearbyPlaces();
    } finally {
      if (mounted) setState(() => isRefreshing = false);
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
                        widget.category,
                        style: AppTextStyles.pageTitle(context),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  SizedBox(width: isPhone ? 24 : 40),
                ],
              ),

              const SizedBox(height: 16),

              // OFFLINE BANNER (Only shows when displaying cached data)
              if (isOffline && places.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.primaryTeal.withOpacity(0.4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.bookmark,
                          color: AppColors.primaryTeal, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Saved from your recent visits',
                        style: TextStyle(
                          color: AppColors.primaryTeal,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

              // FILTER DROPDOWNS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
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
                                value: 1000, child: Text('Within 1 km')),
                            DropdownMenuItem(
                                value: 5000, child: Text('Within 5 km')),
                            DropdownMenuItem(
                                value: 10000, child: Text('Within 10 km')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => selectedDistance = val);
                              _fetchNearbyPlaces();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.cardBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: selectedLimit,
                          isExpanded: true,
                          style: AppTextStyles.categorySubtitle(context),
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('Show 1')),
                            DropdownMenuItem(value: 3, child: Text('Show 3')),
                            DropdownMenuItem(value: 5, child: Text('Show 5')),
                            DropdownMenuItem(value: 10, child: Text('Show 10')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => selectedLimit = val);
                              _fetchNearbyPlaces();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // RESULTS COUNT + REFRESH
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
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh_rounded),
                      color: AppColors.primaryTeal,
                      tooltip: 'Refresh location',
                    ),
                  ],
                ),

              const SizedBox(height: 16),

              // PLACES LIST
              Expanded(
                child: isLoading
                    ? const Center(child: CustomLoadingPin())
                    : places.isEmpty
                        ? Center(
                            child: Text(
                              // If online, show the friendly suggestion. If offline, keep the offline message.
                              hasInternet
                                  ? 'No places found nearby. Try expanding your distance or limit dropdowns above! '
                                  : 'No offline places saved for this category.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.categorySubtitle(context),
                            ),
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: places.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final place = places[index];
                              final double? distanceKm =
                                  place['distance_km'] != null
                                      ? (place['distance_km'] as num).toDouble()
                                      : null;

                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PlaceDetails(
                                        place: Map<String, dynamic>.from(place),
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
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              formatDisplayText(
                                                  place['name'].toString()),
                                              style:
                                                  AppTextStyles.categoryTitle(
                                                      context),
                                            ),
                                          ),
                                          if (distanceKm != null)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryTeal
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
                                                  color: AppColors.primaryTeal,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      if (place['description'] != null)
                                        Text(
                                          place['description'].toString(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.categorySubtitle(
                                              context),
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
