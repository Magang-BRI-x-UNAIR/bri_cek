import 'package:flutter/material.dart';

/// A utility class that provides responsive sizing throughout the app.
///
/// This class automatically calculates and provides dimensions that adapt
/// to different screen sizes, orientations, and device types.
class AppSize {
  // Private constructor to prevent instantiation
  AppSize._();

  // Singleton instance
  static final AppSize _instance = AppSize._();

  // Factory constructor to return the singleton instance
  factory AppSize() => _instance;

  // Screen properties
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double safeAreaHorizontal;
  static late double safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;
  static late EdgeInsets padding;
  static late EdgeInsets viewPadding;
  static late EdgeInsets viewInsets;
  static late double pixelRatio;
  static late Orientation orientation;

  // Device type indicators
  static late bool isSmallScreen;
  static late bool isMediumScreen;
  static late bool isLargeScreen;
  static late bool isTablet;
  static late bool isPhone;

  // Common sizes
  static late double defaultSize;
  static late double paddingHorizontal;
  static late double paddingVertical;
  static late double cardBorderRadius;
  static late double buttonHeight;

  // Font sizes
  static late double titleFontSize;
  static late double subtitleFontSize;
  static late double bodyFontSize;
  static late double smallFontSize;
  static late double captionFontSize;

  // Icon sizes
  static late double iconSize;
  static late double smallIconSize;
  static late double largeIconSize;

  /// Initialize the AppSize with the current BuildContext
  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;

    // Calculate blocks for responsive design (100% of screen = 100 blocks)
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    // Calculate safe area blocks
    padding = _mediaQueryData.padding;
    viewPadding = _mediaQueryData.viewPadding;
    viewInsets = _mediaQueryData.viewInsets;
    pixelRatio = _mediaQueryData.devicePixelRatio;

    safeAreaHorizontal = screenWidth - padding.left - padding.right;
    safeAreaVertical = screenHeight - padding.top - padding.bottom;

    safeBlockHorizontal = safeAreaHorizontal / 100;
    safeBlockVertical = safeAreaVertical / 100;

    // Determine device type
    isSmallScreen = screenWidth < 360;
    isMediumScreen = screenWidth >= 360 && screenWidth < 600;
    isLargeScreen = screenWidth >= 600;
    isTablet = screenWidth >= 600;
    isPhone = screenWidth < 600;

    // Set default size based on device type and orientation
    defaultSize = orientation == Orientation.landscape
        ? screenHeight * 0.024
        : screenWidth * 0.024;

    // Common UI elements sizing
    paddingHorizontal = _getResponsiveSize(15.0, 20.0, 24.0);
    paddingVertical = _getResponsiveSize(12.0, 16.0, 20.0);
    cardBorderRadius = _getResponsiveSize(12.0, 15.0, 18.0);
    buttonHeight = _getResponsiveSize(44.0, 48.0, 56.0);

    // Font sizes
    titleFontSize = _getResponsiveSize(20.0, 24.0, 28.0);
    subtitleFontSize = _getResponsiveSize(16.0, 18.0, 20.0);
    bodyFontSize = _getResponsiveSize(14.0, 16.0, 17.0);
    smallFontSize = _getResponsiveSize(12.0, 13.0, 14.0);
    captionFontSize = _getResponsiveSize(11.0, 12.0, 13.0);

    // Icon sizes
    iconSize = _getResponsiveSize(20.0, 24.0, 28.0);
    smallIconSize = _getResponsiveSize(16.0, 18.0, 20.0);
    largeIconSize = _getResponsiveSize(24.0, 28.0, 32.0);
  }

  /// Returns a size that scales based on screen size category
  static double _getResponsiveSize(double small, double medium, double large) {
    if (isSmallScreen) return small;
    if (isMediumScreen) return medium;
    return large;
  }

  /// Calculates a percentage of screen width
  static double widthPercent(double percent) {
    return safeBlockHorizontal * percent;
  }

  /// Calculates a percentage of screen height
  static double heightPercent(double percent) {
    return safeBlockVertical * percent;
  }

  /// Returns responsive padding for headers based on screen size
  static EdgeInsets getHeaderPadding() {
    return EdgeInsets.only(
      top: heightPercent(4),
      bottom: heightPercent(isPhone ? 6 : 12),
      left: paddingHorizontal,
      right: paddingHorizontal,
    );
  }

  /// Returns responsive padding for content sections
  static EdgeInsets getContentPadding() {
    return EdgeInsets.symmetric(
      horizontal: paddingHorizontal,
      vertical: paddingVertical,
    );
  }

  /// Returns responsive margin for cards
  static EdgeInsets getCardMargin() {
    return EdgeInsets.symmetric(
      horizontal: paddingHorizontal,
      vertical: paddingVertical / 2,
    );
  }

  /// Calculates responsive text styles
  static TextStyle getTextStyle({
    required double fontSize,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.black,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      decoration: decoration,
    );
  }

  /// Returns a responsive title style
  static TextStyle titleStyle(
      {Color color = Colors.black, required double fontSize}) {
    return getTextStyle(
      fontSize: titleFontSize,
      fontWeight: FontWeight.bold,
      color: color,
      height: 1.2,
    );
  }

  /// Returns a responsive body text style
  static TextStyle bodyStyle({Color color = Colors.black}) {
    return getTextStyle(
      fontSize: bodyFontSize,
      color: color,
      height: 1.5,
    );
  }
}
