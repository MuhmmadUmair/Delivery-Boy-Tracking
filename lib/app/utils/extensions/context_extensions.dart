import 'package:firebase_google_apple_notif/app/styles/color_scheme.dart';
import 'package:firebase_google_apple_notif/app/styles/typography.dart';
import 'package:flutter/material.dart';

extension BuildContextExtensions on BuildContext {
  TypographyExtension get typography =>
      Theme.of(this).extension<TypographyExtension>()!;

  AppColorScheme get colors => Theme.of(this).extension<AppColorScheme>()!;
}
