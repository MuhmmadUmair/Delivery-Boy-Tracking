import 'package:firebase_google_apple_notif/app/styles/app_radiuses.dart';
import 'package:firebase_google_apple_notif/app/styles/color_scheme.dart';
import 'package:firebase_google_apple_notif/app/styles/typography.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class ThemeFactory {
  static TypographyExtension createTypography(AppColorScheme colors) =>
      TypographyExtension.from(colors);

  static AppColorScheme get colorSchemeLight => AppColorScheme.light();

  static ThemeData lightThemeData() => ThemeData.light().copyWith(
    extensions: [colorSchemeLight, createTypography(colorSchemeLight)],
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    splashColor: colorSchemeLight.background.withValues(alpha: 0.25),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
      filled: true,
      fillColor: colorSchemeLight.inputBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadiuses.hundredRadius),
        borderSide: BorderSide(
          color: colorSchemeLight.inputBorder.withValues(alpha: 0.10),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadiuses.hundredRadius),
        borderSide: BorderSide(
          color: colorSchemeLight.inputBorder.withValues(alpha: 0.10),
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadiuses.hundredRadius),
        borderSide: BorderSide(color: colorSchemeLight.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadiuses.hundredRadius),
        borderSide: BorderSide(color: colorSchemeLight.error),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadiuses.hundredRadius),
        borderSide: BorderSide(
          color: colorSchemeLight.inputBorder.withValues(),
        ),
      ),
      hintStyle: TextStyle(
        color: colorSchemeLight.onSurface.withValues(alpha: 0.50),
      ),
      errorStyle: TextStyle(color: colorSchemeLight.error),
      iconColor: colorSchemeLight.inputIcon,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colorSchemeLight.cardSecondary,
      dragHandleColor: colorSchemeLight.cardSecondary,
      dragHandleSize: Size(116.w, 8.h),
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadiuses.extraLargeRadius),
        ),
      ),
    ),
  );

  static AppColorScheme get colorSchemeDark => AppColorScheme.dark();

  static ThemeData darkThemeData() => ThemeData.dark().copyWith(
    extensions: [colorSchemeDark, createTypography(colorSchemeDark)],
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: colorSchemeDark.inputIcon,
      selectionColor: colorSchemeDark.inputIcon.withValues(alpha: .2),
      selectionHandleColor: colorSchemeDark.inputIcon.withValues(alpha: .8),
    ),
    splashColor: colorSchemeDark.onSurface.withValues(alpha: 0.25),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
      filled: true,
      fillColor: colorSchemeDark.inputBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadiuses.hundredRadius),
        borderSide: BorderSide(
          color: colorSchemeDark.inputBorder.withValues(alpha: 0.10),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadiuses.hundredRadius),
        borderSide: BorderSide(
          color: colorSchemeDark.inputBorder.withValues(alpha: 0.10),
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadiuses.hundredRadius),
        borderSide: BorderSide(color: colorSchemeDark.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadiuses.hundredRadius),
        borderSide: BorderSide(color: colorSchemeDark.error),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadiuses.hundredRadius),
        borderSide: BorderSide(color: colorSchemeDark.inputBorder.withValues()),
      ),
      hintStyle: TextStyle(
        color: colorSchemeDark.onSurface.withValues(alpha: 0.50),
      ),
      errorStyle: TextStyle(color: colorSchemeDark.error),
      iconColor: colorSchemeDark.inputIcon,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        iconColor: WidgetStatePropertyAll(colorSchemeDark.inputIcon),
        foregroundColor: WidgetStatePropertyAll(colorSchemeDark.inputIcon),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colorSchemeLight.cardSecondary,
      dragHandleColor: colorSchemeLight.cardSecondary,
      dragHandleSize: Size(116.w, 8.h),
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadiuses.extraLargeRadius),
        ),
      ),
    ),
  );
}
