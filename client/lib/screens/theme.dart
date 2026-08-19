import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primaryTeal = Color(0xFF176B68);

  static const backgroundColor = Color.fromARGB(255, 247, 243, 232);

  static const darkText = Color(0xFF1F2933);

  static const secondaryText = Color(0xFF667085);

  static const cardBgColor = Colors.white;
}

class AppSpacing {
  static bool isPhone(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static double horizontal(
    BuildContext context, {
    bool isHome = false,
  }) {
    if (isHome) {
      return isPhone(context) ? 24.0 : 60.0;
    }

    return isPhone(context) ? 20.0 : 40.0;
  }

  static double vertical(BuildContext context) =>
      isPhone(context) ? 20.0 : 30.0;
}

class AppSizes {
  static double logoWidth(BuildContext context) =>
      AppSpacing.isPhone(context) ? 190.0 : 280.0;

  static double headingSize(BuildContext context) =>
      AppSpacing.isPhone(context) ? 32.0 : 42.0;

  static double bodySize(BuildContext context) =>
      AppSpacing.isPhone(context) ? 16.0 : 18.0;

  static double taglineSize(BuildContext context) =>
      AppSpacing.isPhone(context) ? 15.0 : 17.0;
}

// --------------------------------------------------
// GEOGUIDE TYPOGRAPHY
// --------------------------------------------------

class AppTextStyles {
  // Main page headings
  static TextStyle heading(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: AppSizes.headingSize(context),
      fontWeight: FontWeight.bold,
      color: AppColors.darkText,
      height: 1.2,
    );
  }

  // Regular body text
  static TextStyle body(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: AppSizes.bodySize(context),
      color: AppColors.secondaryText,
      height: 1.6,
    );
  }

  // Smaller supporting text
  static TextStyle tagline(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: AppSizes.taglineSize(context),
      fontWeight: FontWeight.w500,
      color: AppColors.darkText,
    );
  }

  // Category page heading
  static TextStyle pageTitle(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: AppSpacing.isPhone(context) ? 20 : 24,
      fontWeight: FontWeight.bold,
      color: AppColors.darkText,
    );
  }

  // Category card title
  static TextStyle categoryTitle(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: AppSpacing.isPhone(context) ? 16 : 18,
      fontWeight: FontWeight.bold,
      color: AppColors.darkText,
    );
  }

  // Category card subtitle
  static TextStyle categorySubtitle(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: AppSpacing.isPhone(context) ? 13 : 14,
      color: AppColors.secondaryText,
    );
  }

  // Button text
  static TextStyle button(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: AppSpacing.isPhone(context) ? 15 : 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );
  }

  // Workflow heading
  static TextStyle workflowHeading(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: AppSpacing.isPhone(context) ? 14 : 16,
      fontWeight: FontWeight.w600,
      color: AppColors.darkText,
    );
  }

  // Workflow step text
  static TextStyle workflowStep(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: AppSpacing.isPhone(context) ? 13 : 14,
      fontWeight: FontWeight.w500,
      color: AppColors.darkText,
    );
  }

  // Bottom GeoGuide tagline
  static TextStyle bottomTagline(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: AppSpacing.isPhone(context) ? 13 : 15,
      fontWeight: FontWeight.w500,
      color: AppColors.secondaryText,
      letterSpacing: 0.2,
    );
  }
}
