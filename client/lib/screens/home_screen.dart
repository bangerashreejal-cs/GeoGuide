import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'theme.dart';
import 'categories_screen.dart';
import 'formatters.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<Position?> _determinePosition(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!context.mounted) return null;

    if (!serviceEnabled) {
      bool? turnOn = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Location Services Disabled'),
            content: const Text(
              'Location services are turned off. Please enable them to use GeoGuide.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Open Settings'),
              ),
            ],
          );
        },
      );

      if (!context.mounted) return null;

      if (turnOn == true) {
        await Geolocator.openLocationSettings();
      }
      return null;
    }

    permission = await Geolocator.requestPermission();
    if (!context.mounted) return null;

    if (permission == LocationPermission.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permissions are denied')),
      );
      return null;
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Location permissions are permanently denied, we cannot request permissions.')),
      );
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          IgnorePointer(
            child: Stack(
              children: [
                Positioned(
                  top: context.screenHeight * 0.08,
                  right: context.screenWidth * 0.08,
                  child: Icon(
                    Icons.explore_outlined,
                    size: context.isPhone ? 90 : 150,
                    color: AppColors.primaryTeal.withOpacity(0.06),
                  ),
                ),
                Positioned(
                  top: context.screenHeight * 0.4,
                  right: context.screenWidth * 0.75,
                  child: Icon(
                    Icons.near_me_outlined,
                    size: context.isPhone ? 75 : 120,
                    color: AppColors.primaryTeal.withOpacity(0.06),
                  ),
                ),
                Positioned(
                  top: context.screenHeight * 0.25,
                  right: context.screenWidth * 0.41,
                  child: Icon(
                    Icons.bolt,
                    size: context.isPhone ? 75 : 120,
                    color: AppColors.primaryTeal.withOpacity(0.06),
                  ),
                ),
                Positioned(
                  top: context.screenHeight * 0.4,
                  right: context.screenWidth * 0.01,
                  child: Icon(
                    Icons.attractions,
                    size: context.isPhone ? 75 : 120,
                    color: AppColors.primaryTeal.withOpacity(0.06),
                  ),
                ),
                Positioned(
                  bottom: context.screenHeight * 0.18,
                  left: context.screenWidth * 0.08,
                  child: Icon(
                    Icons.pedal_bike_outlined,
                    size: context.isPhone ? 80 : 130,
                    color: AppColors.primaryTeal.withOpacity(0.06),
                  ),
                ),
                Positioned(
                  bottom: context.screenHeight * 0.10,
                  right: context.screenWidth * 0.10,
                  child: Icon(
                    Icons.travel_explore_outlined,
                    size: context.isPhone ? 70 : 110,
                    color: AppColors.primaryTeal.withOpacity(0.06),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.horizontal(
                  context,
                  isHome: true,
                ),
                vertical: AppSpacing.vertical(context),
              ),
              child: Column(
                children: [
                  Text(
                    'Welcome To',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.heading(context),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Image.asset(
                      'assets/images/geoguide.png',
                      width: AppSizes.logoWidth(context),
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 700,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Ready to Wander?',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.heading(context),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Tired of endless scrolling and choice paralysis? '
                            'GeoGuide helps you discover food, cultural heritage, '
                            'parks, and hidden gems around you — without the hassle.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body(context),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Your next favorite spot is just a tap away.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.tagline(context),
                          ),
                          const SizedBox(height: 35),
                          ElevatedButton(
                            onPressed: () async {
                              Position? position =
                                  await _determinePosition(context);

                              if (position == null) return;

                              if (context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CategoriesScreen(),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryTeal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 36,
                                vertical: 18,
                              ),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              "Let's Dive In",
                              style: AppTextStyles.button(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Explore nearby. Discover differently.',
                    style: AppTextStyles.bottomTagline(context),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
