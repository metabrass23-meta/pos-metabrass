import 'package:flutter/material.dart';

class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double ultrawide = 1600;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= mobile &&
        MediaQuery.of(context).size.width < desktop;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }

  static bool isUltrawide(BuildContext context) {
    return MediaQuery.of(context).size.width >= ultrawide;
  }

  static String getDeviceType(BuildContext context) {
    if (isMobile(context)) return 'mobile';
    if (isTablet(context)) return 'tablet';
    if (isUltrawide(context)) return 'ultrawide';
    return 'desktop';
  }
}

class ResponsiveHelper {
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Base width for calculations (1200px)
    const double baseWidth = 1200.0;

    // Scale factor calculation
    double scaleFactor = screenWidth / baseWidth;

    // Ensure minimum and maximum scaling
    scaleFactor = scaleFactor.clamp(0.8, 1.5);

    return baseSize * scaleFactor;
  }

  static EdgeInsets getResponsivePadding(BuildContext context, EdgeInsets basePadding) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Base width for calculations (1200px)
    const double baseWidth = 1200.0;

    // Scale factor calculation
    double scaleFactor = screenWidth / baseWidth;

    // Ensure minimum and maximum scaling
    scaleFactor = scaleFactor.clamp(0.8, 1.3);

    return EdgeInsets.fromLTRB(
      basePadding.left * scaleFactor,
      basePadding.top * scaleFactor,
      basePadding.right * scaleFactor,
      basePadding.bottom * scaleFactor,
    );
  }

  static double getResponsiveSize(BuildContext context, double baseSize) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Base width for calculations (1200px)
    const double baseWidth = 1200.0;

    // Scale factor calculation
    double scaleFactor = screenWidth / baseWidth;

    // Ensure minimum and maximum scaling
    scaleFactor = scaleFactor.clamp(0.8, 1.4);

    return baseSize * scaleFactor;
  }
}