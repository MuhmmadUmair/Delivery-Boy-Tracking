import 'dart:ui';

import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The padding/margins or any other spacing used in the design from Figma
/// should be set here.
class AppDimensions {
  // Viewport size of the mobile mockup used in the design on Figma
  static const Size mockSize = Size(375, 812);

  /// 2.0
  static final double extraSmall = 2.0.w;

  /// 4.0
  static final double smallSmall = 4.0.w;

  /// 8.0
  static final double small = 8.0.w;

  /// 12.0
  static final double mediumSmall = 12.0.w;

  /// 16.0
  static final double medium = 16.0.w;

  /// 20.0
  static final double mediumLarge = 20.0.w;

  /// 24.0
  static final double large = 24.0.w;

  /// 28.0
  static final double bigLarge = 28.0.w;

  /// 32.0
  static final double extraLarge = 32.0.w;

  /// 32.0
  static final double bottomNavigationIconHeight = 32.0.h;

  /// 42.0
  static final double settingsBarEmptySpace = 42.0.w;

  /// 80.0
  static final double settingsAvatarSize = 80.0.w;
}
