import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension MediaQueryValues on BuildContext {
  double get mediaQueryHeight => MediaQuery.sizeOf(this).height;
  double get mediaQueryWidth => MediaQuery.sizeOf(this).width;
}

extension EmptySpace on num {
  SizedBox get height => SizedBox(height: toDouble().h);
  SizedBox get width => SizedBox(width: toDouble().w);
}
