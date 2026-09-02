import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'theme.dart';
import 'formatters.dart';
import 'map_screen.dart';

class PlaceDetails extends StatelessWidget {
  final Map<String, dynamic> place;

  const PlaceDetails({
    super.key,
    required this.place,
  });

  // Returns true only when the field actually contains useful information.
  bool _hasValue(String key) {
    final value = place[key];
    return value != null && value.toString().trim().isNotEmpty;
  }

  // Helper to extract coordinates safely from MongoDB GeoJSON or flat fields
  (double, double) _getCoordinates() {
    double lat = 0.0;
    double lng = 0.0;

    if (place['location'] != null && place['location']['coordinates'] != null) {
      final coords = place['location']['coordinates'] as List;
      if (coords.length >= 2) {
        lng = double.tryParse(coords[0].toString()) ?? 0.0;
        lat = double.tryParse(coords[1].toString()) ?? 0.0;
      }
    } else {
      lat = double.tryParse(place['lat']?.toString() ??
              place['latitude']?.toString() ??
              '') ??
          0.0;
      lng = double.tryParse(place['lng']?.toString() ??
              place['longitude']?.toString() ??
              '') ??
          0.0;
    }

    return (lat, lng);
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
                        'Place Details',
                        style: AppTextStyles.pageTitle(context),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: isPhone ? 24 : 40,
                  ),
                ],
              ),

              SizedBox(
                height: isPhone ? 20 : 28,
              ),

              // ============================
              // PLACE NAME
              // ============================
              if (_hasValue('name'))
                Text(
                  formatDisplayText(place['name'].toString()),
                  style: AppTextStyles.pageTitle(context),
                ),

              // ============================
              // CATEGORY + SUBCATEGORY
              // ============================
              if (_hasValue('category') || _hasValue('subcategory'))
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    [
                      if (_hasValue('category')) place['category'].toString(),
                      if (_hasValue('subcategory'))
                        formatDisplayText(place['subcategory'].toString())
                    ].join(' • '),
                    style: AppTextStyles.categorySubtitle(context),
                  ),
                ),

              SizedBox(
                height: isPhone ? 20 : 24,
              ),

              // ============================
              // DETAILS
              // ============================
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Description
                    if (_hasValue('description'))
                      _buildInfoSection(
                        context,
                        icon: Icons.info_outline_rounded,
                        title: 'About',
                        value: place['description'].toString(),
                      ),

                    // Address
                    if (_hasValue('address'))
                      _buildInfoSection(
                        context,
                        icon: Icons.location_on_outlined,
                        title: 'Address',
                        value: place['address'].toString(),
                      ),

                    // Phone
                    if (_hasValue('phone'))
                      _buildInfoSection(
                        context,
                        icon: Icons.phone_outlined,
                        title: 'Phone',
                        value: place['phone'].toString(),
                      ),

                    // Opening hours
                    if (_hasValue('opening_hours'))
                      _buildInfoSection(
                        context,
                        icon: Icons.access_time_rounded,
                        title: 'Opening hours',
                        value: place['opening_hours'].toString(),
                      ),

                    // Website (Clickable)
                    if (_hasValue('website'))
                      _buildInfoSection(
                        context,
                        icon: Icons.language_rounded,
                        title: 'Website',
                        value: place['website'].toString(),
                        isLink: true,
                        onTap: () async {
                          final Uri url =
                              Uri.parse(place['website'].toString());
                          try {
                            await launchUrl(url,
                                mode: LaunchMode.externalApplication);
                          } catch (e) {
                            debugPrint('Could not launch $url: $e');
                          }
                        },
                      ),

                    const SizedBox(height: 16),

                    // ============================
                    // MAP BUTTON
                    // ============================
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final (lat, lng) = _getCoordinates();
                          final name =
                              place['name']?.toString() ?? 'Selected Place';

                          double? currentLat;
                          double? currentLng;

                          try {
                            Position position =
                                await Geolocator.getCurrentPosition(
                              desiredAccuracy: LocationAccuracy.high,
                            );
                            currentLat = position.latitude;
                            currentLng = position.longitude;
                          } catch (e) {
                            debugPrint('Could not fetch current location: $e');
                          }

                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapScreen(
                                  latitude: lat,
                                  longitude: lng,
                                  placeName: name,
                                  currentLatitude: currentLat,
                                  currentLongitude: currentLng,
                                ),
                              ),
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.map_outlined,
                        ),
                        label: const Text(
                          'View on Map',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryTeal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ============================
                    // NAVIGATION BUTTON
                    // ============================
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final (lat, lng) = _getCoordinates();
                          final destinationName = Uri.encodeComponent(
                              place['name'] ?? 'Destination');

                          final Uri mapUrl = kIsWeb
                              ? Uri.parse(
                                  'https://www.google.com/maps/search/?api=1&query=$lat,$lng')
                              : Uri.parse(
                                  'geo:0,0?q=$lat,$lng($destinationName)');

                          if (await canLaunchUrl(mapUrl)) {
                            await launchUrl(
                              mapUrl,
                              mode: kIsWeb
                                  ? LaunchMode.platformDefault
                                  : LaunchMode.externalApplication,
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.navigation_outlined,
                        ),
                        label: const Text(
                          'Navigate',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryTeal,
                          side: BorderSide(
                            color: AppColors.primaryTeal,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // INFORMATION SECTION
  // ==========================================

  Widget _buildInfoSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    bool isLink = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: AppColors.primaryTeal,
                  size: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.categoryTitle(context),
                      ),
                      const SizedBox(height: 4),
                      if (!isLink) ...[
                        Text(
                          value,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
