import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF176B68);
    const backgroundColor = Color.fromARGB(255, 247, 243, 232);
    const darkText = Color(0xFF1F2933);
    const secondaryText = Color(0xFF667085);

    final screenWidth = MediaQuery.of(context).size.width;
    final isPhone = screenWidth < 600;

    final horizontalPadding = isPhone ? 24.0 : 60.0;
    final verticalPadding = isPhone ? 20.0 : 30.0;

    final logoWidth = isPhone ? 190.0 : 280.0;
    final headingSize = isPhone ? 32.0 : 42.0;
    final bodySize = isPhone ? 16.0 : 18.0;
    final taglineSize = isPhone ? 15.0 : 17.0;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Column(
            children: [
              // GeoGuide logo
              Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'assets/images/geoguide.png',
                  width: logoWidth,
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
                          fontSize: headingSize,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          color: darkText,
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
                          fontSize: bodySize,
                          height: 1.6,
                          color: secondaryText,
                        ),
                      ),

                      SizedBox(
                        height: isPhone ? 16 : 20,
                      ),

                      Text(
                        'Your next favorite spot is just a tap away.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: taglineSize,
                          fontWeight: FontWeight.w500,
                          color: darkText,
                        ),
                      ),

                      SizedBox(
                        height: isPhone ? 28 : 35,
                      ),

                      // Explore button
                      ElevatedButton(
                        onPressed: () {
                          // Categories screen will be connected here later.
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryTeal,
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
                  color: secondaryText,
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
