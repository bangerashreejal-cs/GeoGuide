import 'package:flutter/material.dart';
import 'theme.dart';
import 'categories_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isPhone = AppSpacing.isPhone(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          // Decorative background icons
          IgnorePointer(
            child: Stack(
              children: [
                Positioned(
                  top: 80,
                  right: 40,
                  child: Icon(
                    Icons.explore_outlined,
                    size: isPhone ? 100 : 160,
                    color: AppColors.primaryTeal.withOpacity(0.04),
                  ),
                ),
                Positioned(
                  bottom: 120,
                  left: 30,
                  child: Icon(
                    Icons.travel_explore,
                    size: isPhone ? 90 : 140,
                    color: AppColors.primaryTeal.withOpacity(0.04),
                  ),
                ),
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.2,
                  right: 250,
                  child: Icon(
                    Icons.local_see,
                    size: isPhone ? 70 : 110,
                    color: AppColors.primaryTeal.withOpacity(0.03),
                  ),
                ),
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.56,
                  left: 450,
                  child: Icon(
                    Icons.hiking,
                    size: isPhone ? 70 : 110,
                    color: AppColors.primaryTeal.withOpacity(0.03),
                  ),
                ),
              ],
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.horizontal(context, isHome: true),
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
                      constraints: BoxConstraints(
                        maxWidth: isPhone ? 500 : 700,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Ready to Wander?\nWelcome to GeoGuide.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: AppSizes.headingSize(context),
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                              color: AppColors.darkText,
                            ),
                          ),

                          SizedBox(
                            height: isPhone ? 18 : 24,
                          ),

                          Text(
                            'Tired of endless scrolling and choice paralysis? '
                            'GeoGuide helps you discover food, cultural heritage, '
                            'parks, and hidden gems around you — without the hassle.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: AppSizes.bodySize(context),
                              height: 1.6,
                              color: AppColors.secondaryText,
                            ),
                          ),

                          SizedBox(
                            height: isPhone ? 16 : 20,
                          ),

                          Text(
                            'Your next favorite spot is just a tap away.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: AppSizes.taglineSize(context),
                              fontWeight: FontWeight.w500,
                              color: AppColors.darkText,
                            ),
                          ),

                          SizedBox(
                            height: isPhone ? 28 : 35,
                          ),

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
                              padding: EdgeInsets.symmetric(
                                horizontal: isPhone ? 30 : 36,
                                vertical: isPhone ? 16 : 18,
                              ),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              "Let's Dive In",
                              style: TextStyle(
                                fontSize: isPhone ? 15 : 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Footer
                  Text(
                    'Explore the city around you.',
                    style: TextStyle(
                      fontSize: isPhone ? 12 : 14,
                      color: AppColors.secondaryText,
                    ),
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
