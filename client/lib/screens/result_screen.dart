import 'package:flutter/material.dart';
import 'theme.dart';
import '../api_services.dart';

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

  // Filter state variables
  int selectedDistance = 1000; // in meters
  int selectedLimit = 1; // Show places

  @override
  void initState() {
    super.initState();
    _fetchNearbyPlaces();
  }

  Future<void> _fetchNearbyPlaces() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getNearbyPlaces(
        lat: 19.0416956, // Verified dataset latitude
        lng: 73.0362166, // Verified dataset longitude
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
              // Header Row
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
                      ),
                    ),
                  ),
                  SizedBox(width: isPhone ? 24 : 40),
                ],
              ),
              const SizedBox(height: 16),

              // Filter Dropdowns Row (Distance & Limit)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Distance Dropdown
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
                  // Limit Dropdown (1, 3, 5)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.cardBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: selectedLimit,
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
                ],
              ),
              const SizedBox(height: 16),

              // Results Count Status
              isLoading
                  ? const SizedBox.shrink()
                  : Text(
                      '${places.length} places found nearby',
                      style: AppTextStyles.categorySubtitle(context),
                    ),
              const SizedBox(height: 16),

              // Places ListView
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : places.isEmpty
                        ? Center(
                            child: Text(
                              'No places found nearby for this category.',
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
                              // Safely parse distance_km whether it's a double or int
                              final double? distanceKm =
                                  place['distance_km'] != null
                                      ? (place['distance_km'] as num).toDouble()
                                      : null;

                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.cardBgColor,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            place['name'] ?? 'Unnamed place',
                                            style: AppTextStyles.categoryTitle(
                                                context),
                                          ),
                                        ),
                                        if (distanceKm != null)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.green.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              // Check if less than 1 km (1.0)
                                              distanceKm < 1.0
                                                  ? '${(distanceKm * 1000).toStringAsFixed(0)} m' // Convert to meters
                                                  : '${distanceKm.toStringAsFixed(2)} km', // Keep as km
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
