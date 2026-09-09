import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'theme.dart';
import '../api_services.dart';
import '../cached_places.dart';
import 'place_details.dart';
import 'formatters.dart';
import 'loading_screen.dart';

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

  // TRUE = saved/cache data is being displayed.
  // FALSE = fresh API data is being displayed.
  bool isOffline = false;

  bool hasInternet = false;

  // Filter state variables
  int selectedDistance = 1000;
  int selectedLimit = 1;

  StreamSubscription<ServiceStatus>? _serviceStatusStreamSubscription;

  @override
  void initState() {
    super.initState();

    // Start the initial fetch after the first frame so that
    // SnackBars and other inherited widgets are available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchNearbyPlaces();
      }
    });

    // Listen for location services being turned off while
    // the user is already on this screen.
    //
    // getServiceStatusStream() is not supported on Flutter Web,
    // so only use it on Android/iOS/other non-Web platforms.
    if (!kIsWeb) {
      _serviceStatusStreamSubscription =
          Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
        if (status == ServiceStatus.disabled) {
          _showBottomWarning('Please turn on location.');

          // Location is no longer available, so switch to
          // saved mode instead of clearing the screen.
          _loadFromCacheOrEmpty();
        }
      });
    }
  }

  @override
  void dispose() {
    _serviceStatusStreamSubscription?.cancel();
    super.dispose();
  }

  // ------------------------------------------------------------
  // GET CURRENT DEVICE LOCATION
  // ------------------------------------------------------------
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

  // ------------------------------------------------------------
  // CHECK INTERNET CONNECTION
  // ------------------------------------------------------------
  Future<bool> _checkInternetConnection() async {
    try {
      final result = await Connectivity().checkConnectivity();

      return !result.contains(ConnectivityResult.none);
    } catch (_) {
      return false;
    }
  }

  // ------------------------------------------------------------
  // FETCH NEARBY PLACES
  //
  // Fresh mode:
  // Internet ON + Location ON + Backend works
  //
  // Saved mode:
  // Any condition prevents fresh data
  // ------------------------------------------------------------
  Future<void> _fetchNearbyPlaces() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      // ----------------------------------------------------------
      // 1. CHECK INTERNET
      // ----------------------------------------------------------
      final internetAvailable = await _checkInternetConnection();

      if (!internetAvailable) {
        hasInternet = false;

        if (mounted) {
          _showBottomWarning('No internet connection.');
        }

        // Even without internet, check whether location is also off.
        // Saved places do not require location.
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();

        if (!serviceEnabled && mounted) {
          _showBottomWarning('Please turn on location.');
        }

        // No internet → use saved places.
        await _loadFromCacheOrEmpty();
        return;
      }

      // Internet is available.
      hasInternet = true;

      // ----------------------------------------------------------
      // 2. CHECK LOCATION SERVICES
      // ----------------------------------------------------------
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (mounted) {
          _showBottomWarning('Please turn on location.');
        }

        // Internet exists, but location does not.
        // We cannot determine "nearby", so use saved places.
        await _loadFromCacheOrEmpty();
        return;
      }

      // ----------------------------------------------------------
      // 3. GET CURRENT LOCATION
      // ----------------------------------------------------------
      final Position? position = await _determinePosition();

      if (position == null) {
        // Location permission unavailable/denied.
        // Use saved places instead.
        await _loadFromCacheOrEmpty();
        return;
      }

      final double lat = position.latitude;
      final double lng = position.longitude;

      // ----------------------------------------------------------
      // 4. TRY TO GET FRESH DATA FROM RENDER
      // ----------------------------------------------------------
      final data = await ApiService.getNearbyPlaces(
        lat: lat,
        lng: lng,
        maxDistance: selectedDistance,
        limit: selectedLimit,
        category: widget.apiCategory,
      );

      // ----------------------------------------------------------
      // 5. FRESH DATA SUCCESSFULLY RECEIVED
      // ----------------------------------------------------------
      if (!mounted) return;

      setState(() {
        places = data.take(selectedLimit).toList();

        // FALSE = fresh API results.
        // Distance can safely be displayed.
        isOffline = false;

        isLoading = false;
        hasInternet = true;
      });
    } catch (e) {
      print('Error loading nearby places: $e');

      // ----------------------------------------------------------
      // BACKEND / NETWORK FAILURE
      //
      // Internet may technically exist, but Render may be:
      // - sleeping
      // - unavailable
      // - returning an error
      // - taking too long
      //
      // In all cases → saved mode.
      // ----------------------------------------------------------

      if (mounted) {
        _showBottomWarning(
          'Unable to reach the server. Showing saved places.',
        );
      }

      await _loadFromCacheOrEmpty();
    }
  }

  // ------------------------------------------------------------
  // LOAD SAVED / CACHED PLACES
  //
  // IMPORTANT:
  // We do NOT filter using the cached distance.
  //
  // Cached distance may have been calculated from an older
  // location, so it cannot be treated as the user's current
  // distance.
  // ------------------------------------------------------------
  Future<void> _loadFromCacheOrEmpty() async {
    List<Map<String, dynamic>> cachedData = [];

    try {
      cachedData = await PlaceCacheService.getCachedNearbyPlaces(
        category: widget.apiCategory,
      );
    } catch (cacheError) {
      print('Cache read error: $cacheError');
    }

    if (!mounted) return;

    setState(() {
      places = cachedData.take(selectedLimit).toList();

      isLoading = false;

      // TRUE = saved/cache data is being displayed.
      isOffline = true;

      // Internet status itself is not important here.
      // We are explicitly in saved mode.
    });
  }

  // ------------------------------------------------------------
  // SHOW BOTTOM WARNING
  // ------------------------------------------------------------
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

  // ------------------------------------------------------------
  // REFRESH
  //
  // Refresh always tries to obtain fresh data.
  // If that fails, _fetchNearbyPlaces() falls back to cache.
  // ------------------------------------------------------------
  Future<void> _refreshLocation() async {
    if (isRefreshing) return;

    setState(() => isRefreshing = true);

    try {
      await _fetchNearbyPlaces();
    } finally {
      if (mounted) {
        setState(() => isRefreshing = false);
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
              // --------------------------------------------------
              // HEADER
              // --------------------------------------------------
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
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  SizedBox(width: isPhone ? 24 : 40),
                ],
              ),

              const SizedBox(height: 16),

              // --------------------------------------------------
              // SAVED / CACHE BANNER
              // --------------------------------------------------
              if (isOffline && places.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primaryTeal.withOpacity(0.4),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.bookmark,
                        color: AppColors.primaryTeal,
                        size: 20,
                      ),
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

              // --------------------------------------------------
              // FILTER DROPDOWNS
              //
              // Distance filter is ONLY meaningful for fresh
              // results, so hide it in saved mode.
              // --------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // DISTANCE DROPDOWN
                  if (!isOffline)
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

                  if (!isOffline) const SizedBox(width: 12),

                  // LIMIT DROPDOWN
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
                          value: selectedLimit,
                          isExpanded: true,
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

                              if (isOffline) {
                                // In saved mode, only change the
                                // number of cached places displayed.
                                _loadFromCacheOrEmpty();
                              } else {
                                // In fresh mode, ask backend again.
                                _fetchNearbyPlaces();
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // --------------------------------------------------
              // RESULTS COUNT + REFRESH
              // --------------------------------------------------
              if (!isLoading)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isOffline
                          ? '${places.length} saved places'
                          : '${places.length} places found nearby',
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
                          : const Icon(Icons.refresh_rounded),
                      color: AppColors.primaryTeal,
                      tooltip: 'Refresh location',
                    ),
                  ],
                ),

              const SizedBox(height: 16),

              // --------------------------------------------------
              // PLACES LIST
              // --------------------------------------------------
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CustomLoadingPin(),
                      )
                    : places.isEmpty
                        ? Center(
                            child: Text(
                              isOffline
                                  ? 'No saved places available for this category.'
                                  : 'No places found nearby. Try expanding your distance or limit dropdowns above!',
                              textAlign: TextAlign.center,
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

                                          // ------------------------------------------------
                                          // DISTANCE TAG
                                          //
                                          // ONLY displayed for fresh API data.
                                          // Cached distance is intentionally hidden.
                                          // ------------------------------------------------
                                          if (!isOffline && distanceKm != null)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
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
