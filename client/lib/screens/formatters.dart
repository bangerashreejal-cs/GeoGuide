import 'package:flutter/widgets.dart';

String formatDisplayText(String value) {
  // To capitalise place names
  return value
      .replaceAll('_', ' ')
      .split(' ')
      .map(
        (word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}',
      )
      .join(' ');
}

extension ResponsiveExtension on BuildContext {
  //responsive ui for phone
  bool get isPhone => MediaQuery.of(this).size.width < 600;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
}
