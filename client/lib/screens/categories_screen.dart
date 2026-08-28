import 'package:flutter/material.dart';
import 'theme.dart';
import 'result_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isPhone = AppSpacing.isPhone(context);

    final categories = [
      {
        'title': 'Street Food & Cafes',
        'subtitle': 'Bestsellers & quick bites',
        'icon': Icons.local_cafe_rounded,
        'apiCategory': 'Food',
      },
      {
        'title': 'Cultural Heritage',
        'subtitle': 'Historical walks & landmarks',
        'icon': Icons.account_balance_rounded,
        'apiCategory': 'Cultural Heritage',
      },
      {
        'title': 'Parks & Trails',
        'subtitle': 'Green spaces & nature walks',
        'icon': Icons.park_rounded,
        'apiCategory': 'Park/Recreation',
      },
      {
        'title': 'Hidden Gems',
        'subtitle': 'Offbeat local secrets',
        'icon': Icons.explore_rounded,
        'apiCategory': 'Hidden Gem',
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
                        'Explore Categories',
                        style: AppTextStyles.pageTitle(context),
                      ),
                    ),
                  ),

                  // Keeps title centered
                  SizedBox(
                    width: isPhone ? 24 : 40,
                  ),
                ],
              ),

              SizedBox(
                height: isPhone ? 20 : 24,
              ),

              // Subtitle
              Center(
                child: Text(
                  'What are you in the mood for today?',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.categorySubtitle(context).copyWith(
                    fontSize: isPhone ? 15 : 17,
                  ),
                ),
              ),

              SizedBox(
                height: isPhone ? 16 : 20,
              ),

              // Category grid + workflow
              Expanded(
                child: Column(
                  children: [
                    // ============================
                    // CATEGORY GRID
                    // ============================
                    Expanded(
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isPhone ? 1 : 2,
                          mainAxisExtent: isPhone ? 105 : 135,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];

                          return Material(
                            color: AppColors.cardBgColor,
                            borderRadius: BorderRadius.circular(16),
                            elevation: 1,
                            child: InkWell(
                              onTap: () {
                                final String selectedApiCategory =
                                    category['apiCategory'] as String;
                                final String displayTitle =
                                    category['title'] as String;

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ResultScreen(
                                      category: displayTitle,
                                      apiCategory: selectedApiCategory,
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isPhone ? 16 : 20,
                                  vertical: isPhone ? 14 : 16,
                                ),
                                child: Row(
                                  children: [
                                    // Category icon
                                    Container(
                                      width: isPhone ? 48 : 52,
                                      height: isPhone ? 48 : 52,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryTeal
                                            .withOpacity(0.10),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        category['icon'] as IconData,
                                        color: AppColors.primaryTeal,
                                        size: isPhone ? 24 : 26,
                                      ),
                                    ),

                                    SizedBox(
                                      width: isPhone ? 14 : 16,
                                    ),

                                    // Category text
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            category['title'] as String,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTextStyles.categoryTitle(
                                              context,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            category['subtitle'] as String,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                AppTextStyles.categorySubtitle(
                                              context,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    // Arrow
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: isPhone ? 14 : 16,
                                      color: AppColors.secondaryText,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // ============================
                    // HOW GEOGUIDE WORKS
                    // ============================
                    Padding(
                      padding: EdgeInsets.only(
                        top: isPhone ? 12 : 18,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'How GeoGuide works',
                            style: AppTextStyles.workflowHeading(context),
                          ),

                          SizedBox(
                            height: isPhone ? 10 : 12,
                          ),

                          // MOBILE WORKFLOW
                          if (isPhone)
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildWorkflowStep(
                                    context,
                                    number: '1',
                                    text: 'Choose a category',
                                    isPhone: true,
                                  ),
                                  _buildHorizontalArrow(),
                                  _buildWorkflowStep(
                                    context,
                                    number: '2',
                                    text: 'Set your distance',
                                    isPhone: true,
                                  ),
                                  _buildHorizontalArrow(),
                                  _buildWorkflowStep(
                                    context,
                                    number: '3',
                                    text: 'Discover nearby',
                                    isPhone: true,
                                  ),
                                ],
                              ),
                            )

                          // DESKTOP / TABLET WORKFLOW
                          else
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildWorkflowStep(
                                  context,
                                  number: '1',
                                  text: 'Choose a category',
                                  isPhone: false,
                                ),
                                _buildHorizontalArrow(),
                                _buildWorkflowStep(
                                  context,
                                  number: '2',
                                  text: 'Set your distance',
                                  isPhone: false,
                                ),
                                _buildHorizontalArrow(),
                                _buildWorkflowStep(
                                  context,
                                  number: '3',
                                  text: 'Discover nearby',
                                  isPhone: false,
                                ),
                              ],
                            ),

                          SizedBox(
                            height: isPhone ? 12 : 16,
                          ),
                          SizedBox(
                            height: isPhone ? 4 : 8,
                          ),
                        ],
                      ),
                    ),
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
  // WORKFLOW STEP
  // ==========================================

  static Widget _buildWorkflowStep(
    BuildContext context, {
    required String number,
    required String text,
    required bool isPhone,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Number circle
        Container(
          width: isPhone ? 32 : 38,
          height: isPhone ? 32 : 38,
          decoration: BoxDecoration(
            color: AppColors.primaryTeal,
            shape: BoxShape.circle,

            // Subtle cream border
            border: Border.all(
              color: AppColors.backgroundColor,
              width: 3,
            ),

            // Soft teal shadow
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryTeal.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: AppTextStyles.workflowStep(context).copyWith(
              color: Colors.white,
              fontSize: isPhone ? 10 : 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 7),

        // Step description
        Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyles.workflowStep(context).copyWith(
            fontSize:
                isPhone ? 10 : 13, // Adjust 10 to a lower number if needed
          ),
        ),
      ],
    );
  }

  // ==========================================
  // MOBILE ARROW
  // ==========================================

  static Widget _buildWorkflowArrow() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Icon(
        Icons.keyboard_arrow_down_rounded,
        size: 18,
        color: AppColors.secondaryText,
      ),
    );
  }

  // ==========================================
  // DESKTOP ARROW
  // ==========================================

  static Widget _buildHorizontalArrow() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: Icon(
        Icons.arrow_forward_rounded,
        size: 18,
        color: AppColors.secondaryText,
      ),
    );
  }
}
