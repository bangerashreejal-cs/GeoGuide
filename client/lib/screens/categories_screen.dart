import 'package:flutter/material.dart';
import 'theme.dart'; // Adjust path if app_theme.dart is in the same folder

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isPhone = AppSpacing.isPhone(context);

    // Categories list with icons and descriptions
    final categories = [
      {
        'title': 'Street Food & Cafes',
        'subtitle': 'Bestsellers & quick bites',
        'icon': Icons.local_cafe_rounded,
      },
      {
        'title': 'Cultural Heritage',
        'subtitle': 'Historical walks & landmarks',
        'icon': Icons.account_balance_rounded,
      },
      {
        'title': 'Parks & Trails',
        'subtitle': 'Green spaces & nature walks',
        'icon': Icons.park_rounded,
      },
      {
        'title': 'Hidden Gems',
        'subtitle': 'Offbeat local secrets',
        'icon': Icons.explore_rounded,
      },
    ];

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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: AppColors.darkText,
                  ),
                  Text(
                    'Explore Categories',
                    style: TextStyle(
                      fontSize: isPhone ? 20.0 : 24.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(width: 48), // Spacer to balance back button
                ],
              ),

              const SizedBox(height: 24),

              Text(
                'What are you in the mood for today?',
                style: TextStyle(
                  fontSize: isPhone ? 15.0 : 17.0,
                  color: AppColors.secondaryText,
                ),
              ),

              const SizedBox(height: 20),

              // Categories Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isPhone ? 1 : 2,
                    childAspectRatio: isPhone ? 2.8 : 2.2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return InkWell(
                      onTap: () {
                        // TODO: Navigate to specific category listing page
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.cardBgColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.primaryTeal.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                cat['icon'] as IconData,
                                color: AppColors.primaryTeal,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    cat['title'] as String,
                                    style: TextStyle(
                                      fontSize: isPhone ? 16.0 : 18.0,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkText,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    cat['subtitle'] as String,
                                    style: TextStyle(
                                      fontSize: isPhone ? 13.0 : 14.0,
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: AppColors.secondaryText,
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
