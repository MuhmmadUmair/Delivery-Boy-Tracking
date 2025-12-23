import 'package:flutter/material.dart';
import 'typography.dart';
import 'color_scheme.dart';

extension ThemeContextExtension on BuildContext {
  TypographyExtension get typography =>
      Theme.of(this).extension<TypographyExtension>()!;

  AppColorScheme get colors => Theme.of(this).extension<AppColorScheme>()!;
}
