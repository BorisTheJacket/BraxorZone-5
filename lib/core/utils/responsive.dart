import 'package:flutter/material.dart';

class Responsive {
  Responsive._();

  static bool isSmallPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 360;

  static bool isPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 600;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= 600 && w < 1024;
  }

  static bool isLargeTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 1024;

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static double fs(BuildContext context, double base) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < 360) return base * 0.85;
    if (w < 600) return base;
    if (w < 900) return base * 1.1;
    return base * 1.2;
  }

  static double sp(BuildContext context, double base) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < 360) return base * 0.8;
    if (w < 600) return base;
    if (w < 900) return base * 1.25;
    return base * 1.5;
  }

  static int gridColumns(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < 600) return 2;
    if (w < 900) return 3;
    return 4;
  }

  static double hPad(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < 360) return 12.0;
    if (w < 600) return 16.0;
    if (w < 900) return 24.0;
    return 32.0;
  }

  static EdgeInsets screenPadding(BuildContext context) =>
      EdgeInsets.symmetric(horizontal: hPad(context));
}
