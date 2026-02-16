import 'package:flutter/material.dart';

class Responsive {
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

  static bool isSmallPortrait(BuildContext context) => screenWidth(context) < 360;
  static bool isLargePortrait(BuildContext context) => screenWidth(context) >= 360;
  
  static double getFontSize(BuildContext context, double size) {
    // Basic scaling for extreme screen sizes
    double scaleFactor = screenWidth(context) / 400; // Baseline 400px
    if (scaleFactor > 1.2) scaleFactor = 1.2;
    if (scaleFactor < 0.8) scaleFactor = 0.8;
    return size * scaleFactor;
  }

  static double getWidth(BuildContext context, double percentage) {
    return screenWidth(context) * (percentage / 100);
  }

  static double getHeight(BuildContext context, double percentage) {
    return screenHeight(context) * (percentage / 100);
  }

  // Safe padding/spacing
  static double getSafePadding(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }
}
