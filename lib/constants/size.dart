import 'package:flutter/material.dart';

class AppSizes {
  // Get screen width and height from context
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
}
