import 'package:flutter/material.dart';

class AppColorScheme extends ThemeExtension<AppColorScheme> {
  const AppColorScheme({
    // Core colors
    required this.primary,
    required this.background,
    required this.surface,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.outline,
    required this.disabled,
    required this.error,

    // Text colors
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.textOnDark,
    required this.textOnLight,

    // Button colors
    required this.buttonPrimary,
    required this.buttonPrimaryText,
    required this.buttonSecondary,
    required this.buttonSecondaryText,
    required this.buttonDisabled,
    required this.buttonDisabledText,
    required this.bottomSheetPrimary,

    // Input fields
    required this.inputBackground,
    required this.inputText,
    required this.inputBorder,
    required this.inputIcon,
    required this.inputDisabledBackground,
    required this.inputDisabledText,
    required this.inputBackgroundLight,
    required this.inputTextLight,
    required this.inputBorderLight,
    required this.inputIconLight,
    required this.inputDisabledBackgroundLight,
    required this.inputDisabledTextLight,

    // Special components
    required this.ratingStar,
    required this.selectionIndicator,
    required this.nonSelectionIndicator,

    // Cards & Chips
    required this.cardPrimary,
    required this.cardPrimaryText,
    required this.cardSecondary,
    required this.cardSecondaryText,
    required this.cardSecondaryBorder,
    required this.cardTertiary,
    required this.cardTertiaryText,
    required this.cardTertiaryBorder,
    required this.unselectedCard,
    // required this.selectedCard,

    // Navigation
    required this.navBarBackground,
    required this.navBarSelected,
    required this.navBarUnselected,
  });

  factory AppColorScheme.light() => const AppColorScheme(
    // Core colors
    primary: Color(0xff00195a),
    background: Color(0xFF161B25), //update
    surface: Color(0xFFF1F5F9),
    onSurface: Color(0xFF0F172A),
    onSurfaceVariant: Color(0xFF64748B),
    outline: Color(0xFFE2E8F0),
    disabled: Color(0xFFCBD5E1),
    error: Color(0xFFEF4444),

    // Text colors
    textPrimary: Color(0xFF16263D),
    textSecondary: Color(0x9916263D),
    textDisabled: Color(0xFFCBD5E1),
    textOnDark: Color(0xFFFFFFFF),
    textOnLight: Color(0xFF0F172A),

    // Button colors
    buttonPrimary: Color(0xFF226BF7),
    buttonPrimaryText: Color(0xFFFFFFFF),
    buttonSecondary: Color(0xFFF1F5F9),
    buttonSecondaryText: Color(0xFF0F172A),
    buttonDisabled: Color(0xFFE2E8F0),
    buttonDisabledText: Color(0xFF94A3B8),
    bottomSheetPrimary: Color(0xFF2E233D),

    // Input fields
    inputBackground: Color(0xFFF1F5F9),
    inputText: Color(0xFF0F172A),
    inputBorder: Color(0xFFE2E8F0),
    inputIcon: Color(0xFF64748B),
    inputDisabledBackground: Color(0xFFF8FAFC),
    inputDisabledText: Color(0xFFCBD5E1),

    inputBackgroundLight: Color(0xFF99918D),
    inputTextLight: Color(0x00000080),
    inputBorderLight: Color(0x00000080),
    inputIconLight: Color(0xFF64748B),
    inputDisabledBackgroundLight: Color(0xFFF8FAFC),
    inputDisabledTextLight: Color(0xFFCBD5E1),

    // Special components
    ratingStar: Color(0xFFE6D237),
    selectionIndicator: Color(0xFF00195a),
    nonSelectionIndicator: Color(0xFFE2E8F0),

    // Cards & Chips
    cardPrimary: Color(0xFFF1F5F9),
    cardPrimaryText: Color(0xFF0F172A),
    cardSecondary: Color(0xFFFFFFFF),
    cardSecondaryText: Color(0xFF64748B),
    cardSecondaryBorder: Color(0xFFE2E8F0),
    cardTertiary: Color(0xFFE2E8F0),
    cardTertiaryText: Color(0xFF64748B),
    cardTertiaryBorder: Color(0xFFCBD5E1),
    unselectedCard: Color(0xFF505865),
    //selectedCard: Color(0xFFF4E9DC),

    // Navigation
    navBarBackground: Color(0xFFFFFFFF),
    navBarSelected: Color(0xFF00195a),
    navBarUnselected: Color(0xFF94A3B8),
  );

  factory AppColorScheme.dark() => const AppColorScheme(
    // Core colors
    primary: Color(0xFF161B25),
    background: Color(0xFF161B25), //update
    surface: Color(0xFF16263D),
    onSurface: Color(0xFFFAF9F7),
    onSurfaceVariant: Color(0xFF94A3B8),
    outline: Color(0xFF1E293B),
    disabled: Color(0xFF334155),
    error: Color(0xFFF87171),

    // Text colors
    textPrimary: Color(0xFFFAF9F7),
    textSecondary: Color(0xFF94A3B8),
    textDisabled: Color(0xFF475569),
    textOnDark: Color(0xFFFAF9F7),
    textOnLight: Color(0xFF16263D),

    // Button colors
    buttonPrimary: Color(0xFF226BF7),
    buttonPrimaryText: Color(0xFFF4E9DC),
    buttonSecondary: Color(0xFFF4E9DC),
    buttonSecondaryText: Color(0xFF16263D),
    buttonDisabled: Color(0xFF334155),
    buttonDisabledText: Color(0xFF64748B),
    bottomSheetPrimary: Color(0xFF2E323D),

    // Input fields
    inputBackground: Color(0xFF3C4554),
    inputText: Color(0x99FAF9F7), // 60% opacity
    inputBorder: Color(0xFF99918D), // 10% opacity
    inputIcon: Color(0xFFF4E9DC),
    inputDisabledBackground: Color(0xFF1E293B),
    inputDisabledText: Color(0x8064758B), // 50% opacity

    inputBackgroundLight: Color(0xFF99918D),
    inputTextLight: Color(0x00000080),
    inputBorderLight: Color(0x00000080),
    inputIconLight: Color(0xFF64748B),
    inputDisabledBackgroundLight: Color(0xFFF8FAFC),
    inputDisabledTextLight: Color(0xFFCBD5E1),

    // Special components
    ratingStar: Color(0xFFE6D237),
    selectionIndicator: Color(0xFFF4E9DC),
    nonSelectionIndicator: Color(0xFF3C4554),

    // Cards & Chips
    // cardPrimary: Color(0xFFF4E9DC),
    cardPrimary: Color.fromARGB(255, 226, 236, 251),
    cardPrimaryText: Color(0xFF16263D),
    cardSecondary: Color(0xFFFAF9F7),
    cardSecondaryText: Color(0x9916263D), // 60% opacity
    cardSecondaryBorder: Color(0x9916263D), // 60% opacity
    cardTertiary: Color(0xFF3C4554),
    cardTertiaryText: Color(0x80FAF8F7), // 50% opacity
    cardTertiaryBorder: Color(0x0FFAF9F7), // 6% opacity
    unselectedCard: Color(0xFF505865),
    //selectedCard: Color(0xFFF4E9DC),

    // Navigation
    navBarBackground: Color(0xFF3C4554),
    navBarSelected: Color(0xFFF4E9DC),
    navBarUnselected: Color(0x80FAF9F7), // 50% opacity
  );

  // Core colors
  final Color primary;
  final Color background;
  final Color surface;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color outline;
  final Color disabled;
  final Color error;

  // Text colors
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color textOnDark;
  final Color textOnLight;

  // Button colors
  final Color buttonPrimary;
  final Color buttonPrimaryText;
  final Color buttonSecondary;
  final Color buttonSecondaryText;
  final Color buttonDisabled;
  final Color buttonDisabledText;
  final Color bottomSheetPrimary;

  // Input fields
  final Color inputBackground;
  final Color inputText;
  final Color inputBorder;
  final Color inputIcon;
  final Color inputDisabledBackground;
  final Color inputDisabledText;

  // Input fields Light
  final Color inputBackgroundLight;
  final Color inputTextLight;
  final Color inputBorderLight;
  final Color inputIconLight;
  final Color inputDisabledBackgroundLight;
  final Color inputDisabledTextLight;

  // Special components
  final Color ratingStar;
  final Color selectionIndicator;
  final Color nonSelectionIndicator;

  // Cards & Chips
  final Color cardPrimary;
  final Color cardPrimaryText;
  final Color cardSecondary;
  final Color cardSecondaryText;
  final Color cardSecondaryBorder;
  final Color cardTertiary;
  final Color cardTertiaryText;
  final Color cardTertiaryBorder;
  final Color unselectedCard;
  // final Color selectedCard;

  // Navigation
  final Color navBarBackground;
  final Color navBarSelected;
  final Color navBarUnselected;

  @override
  AppColorScheme copyWith({
    Color? primary,
    Color? background,
    Color? surface,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? outline,
    Color? disabled,
    Color? error,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
    Color? textOnDark,
    Color? textOnLight,
    Color? buttonPrimary,
    Color? buttonPrimaryText,
    Color? buttonSecondary,
    Color? buttonSecondaryText,
    Color? buttonDisabled,
    Color? buttonDisabledText,
    Color? bottomSheetPrimary,
    Color? inputBackground,
    Color? inputText,
    Color? inputBorder,
    Color? inputIcon,
    Color? inputDisabledBackground,
    Color? inputDisabledText,
    Color? inputBackgroundLight,
    Color? inputTextLight,
    Color? inputBorderLight,
    Color? inputIconLight,
    Color? inputDisabledBackgroundLight,
    Color? inputDisabledTextLight,
    Color? ratingStar,
    Color? selectionIndicator,
    Color? nonSelectionIndicator,
    Color? cardPrimary,
    Color? cardPrimaryText,
    Color? cardSecondary,
    Color? cardSecondaryText,
    Color? cardSecondaryBorder,
    Color? cardTertiary,
    Color? cardTertiaryText,
    Color? cardTertiaryBorder,
    Color? navBarBackground,
    Color? navBarSelected,
    Color? navBarUnselected,
    // Color? selectedCard,
    Color? unselectedCard,
  }) {
    return AppColorScheme(
      primary: primary ?? this.primary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      outline: outline ?? this.outline,
      disabled: disabled ?? this.disabled,
      error: error ?? this.error,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
      textOnDark: textOnDark ?? this.textOnDark,
      textOnLight: textOnLight ?? this.textOnLight,
      buttonPrimary: buttonPrimary ?? this.buttonPrimary,
      buttonPrimaryText: buttonPrimaryText ?? this.buttonPrimaryText,
      buttonSecondary: buttonSecondary ?? this.buttonSecondary,
      buttonSecondaryText: buttonSecondaryText ?? this.buttonSecondaryText,
      buttonDisabled: buttonDisabled ?? this.buttonDisabled,
      buttonDisabledText: buttonDisabledText ?? this.buttonDisabledText,
      bottomSheetPrimary: bottomSheetPrimary ?? this.bottomSheetPrimary,
      inputBackground: inputBackground ?? this.inputBackground,
      inputText: inputText ?? this.inputText,
      inputBorder: inputBorder ?? this.inputBorder,
      inputIcon: inputIcon ?? this.inputIcon,
      inputDisabledBackground:
          inputDisabledBackground ?? this.inputDisabledBackground,
      inputDisabledText: inputDisabledText ?? this.inputDisabledText,
      inputBackgroundLight: inputBackgroundLight ?? this.inputBackgroundLight,
      inputTextLight: inputTextLight ?? this.inputTextLight,
      inputBorderLight: inputBorderLight ?? this.inputBorderLight,
      inputIconLight: inputIconLight ?? this.inputIconLight,
      inputDisabledBackgroundLight:
          inputDisabledBackgroundLight ?? this.inputDisabledBackgroundLight,
      inputDisabledTextLight:
          inputDisabledTextLight ?? this.inputDisabledTextLight,
      ratingStar: ratingStar ?? this.ratingStar,
      selectionIndicator: selectionIndicator ?? this.selectionIndicator,
      nonSelectionIndicator:
          nonSelectionIndicator ?? this.nonSelectionIndicator,
      cardPrimary: cardPrimary ?? this.cardPrimary,
      cardPrimaryText: cardPrimaryText ?? this.cardPrimaryText,
      cardSecondary: cardSecondary ?? this.cardSecondary,
      cardSecondaryText: cardSecondaryText ?? this.cardSecondaryText,
      cardSecondaryBorder: cardSecondaryBorder ?? this.cardSecondaryBorder,
      cardTertiary: cardTertiary ?? this.cardTertiary,
      cardTertiaryText: cardTertiaryText ?? this.cardTertiaryText,
      cardTertiaryBorder: cardTertiaryBorder ?? this.cardTertiaryBorder,
      navBarBackground: navBarBackground ?? this.navBarBackground,
      navBarSelected: navBarSelected ?? this.navBarSelected,
      navBarUnselected: navBarUnselected ?? this.navBarUnselected,
      unselectedCard: unselectedCard ?? this.unselectedCard,
    );
    //selectedCard: selectedCard ?? this.selectedCard);
  }

  @override
  ThemeExtension<AppColorScheme> lerp(
    ThemeExtension<AppColorScheme>? other,
    double t,
  ) {
    if (other is! AppColorScheme) return this;

    return AppColorScheme(
      primary: Color.lerp(primary, other.primary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceVariant: Color.lerp(
        onSurfaceVariant,
        other.onSurfaceVariant,
        t,
      )!,
      outline: Color.lerp(outline, other.outline, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      error: Color.lerp(error, other.error, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      textOnDark: Color.lerp(textOnDark, other.textOnDark, t)!,
      textOnLight: Color.lerp(textOnLight, other.textOnLight, t)!,
      buttonPrimary: Color.lerp(buttonPrimary, other.buttonPrimary, t)!,
      buttonPrimaryText: Color.lerp(
        buttonPrimaryText,
        other.buttonPrimaryText,
        t,
      )!,
      buttonSecondary: Color.lerp(buttonSecondary, other.buttonSecondary, t)!,
      buttonSecondaryText: Color.lerp(
        buttonSecondaryText,
        other.buttonSecondaryText,
        t,
      )!,
      buttonDisabled: Color.lerp(buttonDisabled, other.buttonDisabled, t)!,
      buttonDisabledText: Color.lerp(
        buttonDisabledText,
        other.buttonDisabledText,
        t,
      )!,
      inputBackground: Color.lerp(inputBackground, other.inputBackground, t)!,
      inputText: Color.lerp(inputText, other.inputText, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      inputIcon: Color.lerp(inputIcon, other.inputIcon, t)!,
      inputDisabledBackground: Color.lerp(
        inputDisabledBackground,
        other.inputDisabledBackground,
        t,
      )!,
      inputDisabledText: Color.lerp(
        inputDisabledText,
        other.inputDisabledText,
        t,
      )!,
      inputBackgroundLight: Color.lerp(
        inputBackgroundLight,
        other.inputBackgroundLight,
        t,
      )!,
      inputTextLight: Color.lerp(inputTextLight, other.inputTextLight, t)!,
      inputBorderLight: Color.lerp(
        inputBorderLight,
        other.inputBorderLight,
        t,
      )!,
      inputIconLight: Color.lerp(inputIconLight, other.inputIconLight, t)!,
      inputDisabledBackgroundLight: Color.lerp(
        inputDisabledBackgroundLight,
        other.inputDisabledBackgroundLight,
        t,
      )!,
      inputDisabledTextLight: Color.lerp(
        inputDisabledTextLight,
        other.inputDisabledTextLight,
        t,
      )!,
      ratingStar: Color.lerp(ratingStar, other.ratingStar, t)!,
      selectionIndicator: Color.lerp(
        selectionIndicator,
        other.selectionIndicator,
        t,
      )!,
      nonSelectionIndicator: Color.lerp(
        nonSelectionIndicator,
        other.nonSelectionIndicator,
        t,
      )!,
      cardPrimary: Color.lerp(cardPrimary, other.cardPrimary, t)!,
      cardPrimaryText: Color.lerp(cardPrimaryText, other.cardPrimaryText, t)!,
      cardSecondary: Color.lerp(cardSecondary, other.cardSecondary, t)!,
      cardSecondaryText: Color.lerp(
        cardSecondaryText,
        other.cardSecondaryText,
        t,
      )!,
      cardSecondaryBorder: Color.lerp(
        cardSecondaryBorder,
        other.cardSecondaryBorder,
        t,
      )!,
      cardTertiary: Color.lerp(cardTertiary, other.cardTertiary, t)!,
      cardTertiaryText: Color.lerp(
        cardTertiaryText,
        other.cardTertiaryText,
        t,
      )!,
      cardTertiaryBorder: Color.lerp(
        cardTertiaryBorder,
        other.cardTertiaryBorder,
        t,
      )!,
      navBarBackground: Color.lerp(
        navBarBackground,
        other.navBarBackground,
        t,
      )!,
      navBarSelected: Color.lerp(navBarSelected, other.navBarSelected, t)!,
      navBarUnselected: Color.lerp(
        navBarUnselected,
        other.navBarUnselected,
        t,
      )!,
      unselectedCard: Color.lerp(unselectedCard, other.unselectedCard, t)!,
      bottomSheetPrimary: bottomSheetPrimary,
      //selectedCard: Color.lerp(//selectedCard, other.//selectedCard, t)!,
    );
  }
}
