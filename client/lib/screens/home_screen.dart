import 'package:flutter/material.dart';
import 'theme.dart';
import 'categories_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isPhone = AppSpacing.isPhone(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          // Background Watermark Icons
          IgnorePointer(
            child: Stack(
              children: [
                Positioned(
                  top: screenSize.height * 0.08,
                  right: 30,
                  child: Icon(
                    Icons.explore_outlined,
                    size: isPhone ? 100 : 150,
                    color: AppColors.primaryTeal.withOpacity(0.06),
                  ),
                ),
                Positioned(
                  top: screenSize.height * 0.32,
                  left: 350,
                  child: Icon(
                    Icons.near_me_outlined,
                    size: isPhone ? 80 : 120,
                    color: AppColors.primaryTeal.withOpacity(0.06),
                  ),
                ),
                Positioned(
                  bottom: screenSize.height * 0.18,
                  left: 35,
                  child: Icon(
                    Icons.pedal_bike_outlined,
                    size: isPhone ? 85 : 130,
                    color: AppColors.primaryTeal.withOpacity(0.06),
                  ),
                ),
                Positioned(
                  bottom: screenSize.height * 0.27,
                  right: 150,
                  child: Icon(
                    Icons.travel_explore_outlined,
                    size: isPhone ? 75 : 110,
                    color: AppColors.primaryTeal.withOpacity(0.06),
                  ),
                ),
              ],
            ),
          ),

          // Main Screen Content
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
                  // GeoGuide logo
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      'assets/images/geoguide.png',
                      width: AppSizes.logoWidth(context),
                      filterQuality: FilterQuality.high,
                    ),
                  ),

                  const Spacer(),

                  // Welcome section
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 700,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Ready to Wander?\nWelcome to GeoGuide',
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

                          // Explore button
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CategoriesScreen(),
                                ),
                              );
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

                  // Footer
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
