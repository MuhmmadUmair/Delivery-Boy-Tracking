import 'package:firebase_google_apple_notif/app/styles/color_scheme.dart';
import 'package:firebase_google_apple_notif/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TypographyExtension extends ThemeExtension<TypographyExtension> {
  TypographyExtension({
    required this.displayLarge,
    required this.displayMedium,
    required this.displaySmall,
    required this.headline,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.bodySmall,
    required this.label,
    required this.labelSmall,
    required this.caption,
    required this.description,
    required this.highlight,
    required this.button,
  });

  factory TypographyExtension.from(AppColorScheme colors) =>
      TypographyExtension(
        button: TextStyle(
          fontFamily: FontFamily.raleway,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
        displayLarge: TextStyle(
          fontFamily: FontFamily.raleway,
          fontSize: 32.sp,
          fontWeight: FontWeight.w500,
          color: colors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontFamily: FontFamily.raleway,
          fontSize: 28.sp,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
        displaySmall: TextStyle(
          fontFamily: FontFamily.raleway,
          fontSize: 24.sp,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
        headline: TextStyle(
          fontFamily: FontFamily.raleway,
          fontSize: 19.sp,
          fontWeight: FontWeight.w500,
          color: colors.textPrimary,
        ),
        title: TextStyle(
          fontFamily: FontFamily.raleway,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
        subtitle: TextStyle(
          fontFamily: FontFamily.raleway,
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: colors.textOnLight.withValues(alpha: 0.60),
        ),
        body: TextStyle(
          fontFamily: FontFamily.raleway,
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          color: colors.onSurface,
        ),
        bodySmall: TextStyle(
          fontFamily: FontFamily.raleway,
          fontSize: 13.sp,
          fontWeight: FontWeight.w400,
          color: colors.onSurface,
        ),
        label: TextStyle(
          fontFamily: FontFamily.raleway,
          fontSize: 11.sp,
          fontWeight: FontWeight.w400,
          color: colors.textPrimary,
        ),
        labelSmall: TextStyle(
          fontFamily: FontFamily.raleway,
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: colors.textPrimary,
        ),
        caption: TextStyle(
          fontFamily: FontFamily.raleway,
          fontSize: 9.sp,
          fontWeight: FontWeight.w500,
          color: colors.textPrimary,
        ),
        description: TextStyle(
          fontFamily: FontFamily.raleway,
          fontSize: 8.sp,
          fontWeight: FontWeight.w400,
          color: colors.textSecondary,
        ),
        highlight: TextStyle(
          fontFamily: FontFamily.raleway,
          fontSize: 20.sp,
          fontWeight: FontWeight.w900,
          color: colors.textPrimary,
        ),
      );

  final TextStyle displayLarge;
  final TextStyle displayMedium;
  final TextStyle displaySmall;
  final TextStyle headline;
  final TextStyle title;
  final TextStyle subtitle;
  final TextStyle body;
  final TextStyle bodySmall;
  final TextStyle label;
  final TextStyle labelSmall;
  final TextStyle caption;
  final TextStyle description;
  final TextStyle highlight;
  final TextStyle button;

  @override
  TypographyExtension copyWith({
    TextStyle? displayLarge,
    TextStyle? displayMedium,
    TextStyle? displaySmall,
    TextStyle? headline,
    TextStyle? title,
    TextStyle? subtitle,
    TextStyle? body,
    TextStyle? bodySmall,
    TextStyle? label,
    TextStyle? labelSmall,
    TextStyle? caption,
    TextStyle? description,
    TextStyle? highlight,
    TextStyle? button,
  }) => TypographyExtension(
    displayLarge: displayLarge ?? this.displayLarge,
    displayMedium: displayMedium ?? this.displayMedium,
    displaySmall: displaySmall ?? this.displaySmall,
    headline: headline ?? this.headline,
    title: title ?? this.title,
    subtitle: subtitle ?? this.subtitle,
    body: body ?? this.body,
    bodySmall: bodySmall ?? this.bodySmall,
    label: label ?? this.label,
    labelSmall: labelSmall ?? this.labelSmall,
    caption: caption ?? this.caption,
    description: description ?? this.description,
    highlight: highlight ?? this.highlight,
    button: button ?? this.button,
  );

  @override
  ThemeExtension<TypographyExtension> lerp(
    ThemeExtension<TypographyExtension>? other,
    double t,
  ) {
    if (other is! TypographyExtension) return this;

    return TypographyExtension(
      displayLarge: TextStyle.lerp(displayLarge, other.displayLarge, t)!,
      displayMedium: TextStyle.lerp(displayMedium, other.displayMedium, t)!,
      displaySmall: TextStyle.lerp(displaySmall, other.displaySmall, t)!,
      headline: TextStyle.lerp(headline, other.headline, t)!,
      title: TextStyle.lerp(title, other.title, t)!,
      subtitle: TextStyle.lerp(subtitle, other.subtitle, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      label: TextStyle.lerp(label, other.label, t)!,
      labelSmall: TextStyle.lerp(labelSmall, other.labelSmall, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
      description: TextStyle.lerp(description, other.description, t)!,
      highlight: TextStyle.lerp(highlight, other.highlight, t)!,
      button: TextStyle.lerp(button, other.button, t)!,
    );
  }
}
