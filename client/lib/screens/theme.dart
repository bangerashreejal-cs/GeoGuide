import 'package:flutter/material.dart';

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

  static double horizontal(BuildContext context, {bool isHome = false}) {
    if (isHome) return isPhone(context) ? 24.0 : 60.0;
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
