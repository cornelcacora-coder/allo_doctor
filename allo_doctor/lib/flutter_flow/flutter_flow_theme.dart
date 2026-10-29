// ignore_for_file: overridden_fields, annotate_overrides

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shared_preferences/shared_preferences.dart';

const kThemeModeKey = '__theme_mode__';

SharedPreferences? _prefs;

abstract class FlutterFlowTheme {
  static Future initialize() async =>
      _prefs = await SharedPreferences.getInstance();

  static ThemeMode get themeMode {
    final darkMode = _prefs?.getBool(kThemeModeKey);
    return darkMode == null
        ? ThemeMode.system
        : darkMode
            ? ThemeMode.dark
            : ThemeMode.light;
  }

  static void saveThemeMode(ThemeMode mode) => mode == ThemeMode.system
      ? _prefs?.remove(kThemeModeKey)
      : _prefs?.setBool(kThemeModeKey, mode == ThemeMode.dark);

  static FlutterFlowTheme of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? DarkModeTheme()
        : LightModeTheme();
  }

  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color primary;
  late Color secondary;
  late Color tertiary;
  late Color alternate;
  late Color primaryText;
  late Color secondaryText;
  late Color primaryBackground;
  late Color secondaryBackground;
  late Color accent1;
  late Color accent2;
  late Color accent3;
  late Color accent4;
  late Color success;
  late Color warning;
  late Color error;
  late Color info;

  late Color black30;
  late Color black20;
  late Color accent5;
  late Color lightGray;
  late Color shadowColor;
  late Color borderColor;
  late Color grey;
  late Color customColor1;
  late Color hint;
  late Color divider;
  late Color onPrimary;
  late Color primaryContainer;
  late Color onPrimaryContainer;
  late Color onSecondary;
  late Color secondaryContainer;
  late Color onSecondaryContainer;
  late Color onAccent;
  late Color accentContainer;
  late Color onAccentContainer;
  late Color onBackground;
  late Color onSurface;
  late Color surfaceVariant;
  late Color onSurfaceVariant;
  late Color onSuccess;
  late Color onWarning;
  late Color onError;
  late Color onInfo;
  late Color transparent;
  late Color fullContrast;
  late Color surface20;
  late Color onPrimary90;
  late Color secondaryText40;
  late Color onprimary5;
  late Color onPrimary20;
  late Color onWarning13;
  late Color surface15;
  late Color onSurface80;
  late Color onPrimary70;
  late Color onWarning20;
  late Color surface10;
  late Color onsurface90;
  late Color onsurface70;
  late Color onprimary80;
  late Color error10;
  late Color success10;
  late Color error30;
  late Color success30;
  late Color onbackground90;
  late Color accent50;
  late Color secondarytext50;
  late Color onprimary15;
  late Color onprimary10;
  late Color warning10;
  late Color primary10;
  late Color primarytext80;
  late Color onbackground80;
  late Color info10;

  FFDesignTokens get designToken => FFDesignTokens(this);

  @Deprecated('Use displaySmallFamily instead')
  String get title1Family => displaySmallFamily;
  @Deprecated('Use displaySmall instead')
  TextStyle get title1 => typography.displaySmall;
  @Deprecated('Use headlineMediumFamily instead')
  String get title2Family => typography.headlineMediumFamily;
  @Deprecated('Use headlineMedium instead')
  TextStyle get title2 => typography.headlineMedium;
  @Deprecated('Use headlineSmallFamily instead')
  String get title3Family => typography.headlineSmallFamily;
  @Deprecated('Use headlineSmall instead')
  TextStyle get title3 => typography.headlineSmall;
  @Deprecated('Use titleMediumFamily instead')
  String get subtitle1Family => typography.titleMediumFamily;
  @Deprecated('Use titleMedium instead')
  TextStyle get subtitle1 => typography.titleMedium;
  @Deprecated('Use titleSmallFamily instead')
  String get subtitle2Family => typography.titleSmallFamily;
  @Deprecated('Use titleSmall instead')
  TextStyle get subtitle2 => typography.titleSmall;
  @Deprecated('Use bodyMediumFamily instead')
  String get bodyText1Family => typography.bodyMediumFamily;
  @Deprecated('Use bodyMedium instead')
  TextStyle get bodyText1 => typography.bodyMedium;
  @Deprecated('Use bodySmallFamily instead')
  String get bodyText2Family => typography.bodySmallFamily;
  @Deprecated('Use bodySmall instead')
  TextStyle get bodyText2 => typography.bodySmall;

  String get displayLargeFamily => typography.displayLargeFamily;
  bool get displayLargeIsCustom => typography.displayLargeIsCustom;
  TextStyle get displayLarge => typography.displayLarge;
  String get displayMediumFamily => typography.displayMediumFamily;
  bool get displayMediumIsCustom => typography.displayMediumIsCustom;
  TextStyle get displayMedium => typography.displayMedium;
  String get displaySmallFamily => typography.displaySmallFamily;
  bool get displaySmallIsCustom => typography.displaySmallIsCustom;
  TextStyle get displaySmall => typography.displaySmall;
  String get headlineLargeFamily => typography.headlineLargeFamily;
  bool get headlineLargeIsCustom => typography.headlineLargeIsCustom;
  TextStyle get headlineLarge => typography.headlineLarge;
  String get headlineMediumFamily => typography.headlineMediumFamily;
  bool get headlineMediumIsCustom => typography.headlineMediumIsCustom;
  TextStyle get headlineMedium => typography.headlineMedium;
  String get headlineSmallFamily => typography.headlineSmallFamily;
  bool get headlineSmallIsCustom => typography.headlineSmallIsCustom;
  TextStyle get headlineSmall => typography.headlineSmall;
  String get titleLargeFamily => typography.titleLargeFamily;
  bool get titleLargeIsCustom => typography.titleLargeIsCustom;
  TextStyle get titleLarge => typography.titleLarge;
  String get titleMediumFamily => typography.titleMediumFamily;
  bool get titleMediumIsCustom => typography.titleMediumIsCustom;
  TextStyle get titleMedium => typography.titleMedium;
  String get titleSmallFamily => typography.titleSmallFamily;
  bool get titleSmallIsCustom => typography.titleSmallIsCustom;
  TextStyle get titleSmall => typography.titleSmall;
  String get labelLargeFamily => typography.labelLargeFamily;
  bool get labelLargeIsCustom => typography.labelLargeIsCustom;
  TextStyle get labelLarge => typography.labelLarge;
  String get labelMediumFamily => typography.labelMediumFamily;
  bool get labelMediumIsCustom => typography.labelMediumIsCustom;
  TextStyle get labelMedium => typography.labelMedium;
  String get labelSmallFamily => typography.labelSmallFamily;
  bool get labelSmallIsCustom => typography.labelSmallIsCustom;
  TextStyle get labelSmall => typography.labelSmall;
  String get bodyLargeFamily => typography.bodyLargeFamily;
  bool get bodyLargeIsCustom => typography.bodyLargeIsCustom;
  TextStyle get bodyLarge => typography.bodyLarge;
  String get bodyMediumFamily => typography.bodyMediumFamily;
  bool get bodyMediumIsCustom => typography.bodyMediumIsCustom;
  TextStyle get bodyMedium => typography.bodyMedium;
  String get bodySmallFamily => typography.bodySmallFamily;
  bool get bodySmallIsCustom => typography.bodySmallIsCustom;
  TextStyle get bodySmall => typography.bodySmall;

  Typography get typography => ThemeTypography(this);
}

class LightModeTheme extends FlutterFlowTheme {
  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color primary = const Color(0xFF0F766E);
  late Color secondary = const Color(0xFF14B8A6);
  late Color tertiary = const Color(0xFF0F766E);
  late Color alternate = const Color(0xFFE0E5E3);
  late Color primaryText = const Color(0xFF1A1C1B);
  late Color secondaryText = const Color(0xFF56605B);
  late Color primaryBackground = const Color(0xFFF8F9FA);
  late Color secondaryBackground = const Color(0xFFFFFFFF);
  late Color accent1 = const Color(0xFFF4A261);
  late Color accent2 = const Color(0x4D39D2C0);
  late Color accent3 = const Color(0xFFA0A8A4);
  late Color accent4 = const Color(0xFFE5E5E5);
  late Color success = const Color(0xFF25674D);
  late Color warning = const Color(0xFFFFB300);
  late Color error = const Color(0xFFBE3232);
  late Color info = const Color(0xFF4A8D72);

  late Color black30 = const Color(0xFFC0C0C0);
  late Color black20 = const Color(0xFFDCDCDC);
  late Color accent5 = const Color(0x34D2C239);
  late Color lightGray = const Color(0xFFF8F8F8);
  late Color shadowColor = const Color(0x14000000);
  late Color borderColor = const Color(0xFFDADDDD);
  late Color grey = const Color(0xFFF4F4F4);
  late Color customColor1 = const Color(0xFF737373);
  late Color hint = const Color(0xFF9CA3AF);
  late Color divider = const Color(0xFFE5E7EB);
  late Color onPrimary = const Color(0xFFFFFFFF);
  late Color primaryContainer = const Color(0x1A0F766E);
  late Color onPrimaryContainer = const Color(0xFF1A1C1B);
  late Color onSecondary = const Color(0xFFFFFFFF);
  late Color secondaryContainer = const Color(0x1A14B8A6);
  late Color onSecondaryContainer = const Color(0xFF1A1C1B);
  late Color onAccent = const Color(0xFFFFFFFF);
  late Color accentContainer = const Color(0x1A0F766E);
  late Color onAccentContainer = const Color(0xFF1A1C1B);
  late Color onBackground = const Color(0xFF1A1C1B);
  late Color onSurface = const Color(0xFF1A1C1B);
  late Color surfaceVariant = const Color(0xFFF2F5F4);
  late Color onSurfaceVariant = const Color(0xFF56605B);
  late Color onSuccess = const Color(0xFFFFFFFF);
  late Color onWarning = const Color(0xFF000000);
  late Color onError = const Color(0xFFFFFFFF);
  late Color onInfo = const Color(0xFFFFFFFF);
  late Color transparent = const Color(0x00000000);
  late Color fullContrast = const Color(0xFF000000);
  late Color surface20 = const Color(0x33FFFFFF);
  late Color onPrimary90 = const Color(0xE6FFFFFF);
  late Color secondaryText40 = const Color(0x6656605B);
  late Color onprimary5 = const Color(0x0DFFFFFF);
  late Color onPrimary20 = const Color(0x33FFFFFF);
  late Color onWarning13 = const Color(0x21000000);
  late Color surface15 = const Color(0x26FFFFFF);
  late Color onSurface80 = const Color(0xCC1A1C1B);
  late Color onPrimary70 = const Color(0xB3FFFFFF);
  late Color onWarning20 = const Color(0x33000000);
  late Color surface10 = const Color(0x1AFFFFFF);
  late Color onsurface90 = const Color(0xE61A1C1B);
  late Color onsurface70 = const Color(0xB31A1C1B);
  late Color onprimary80 = const Color(0xCCFFFFFF);
  late Color error10 = const Color(0x1ABE3232);
  late Color success10 = const Color(0x1A25674D);
  late Color error30 = const Color(0x4DBE3232);
  late Color success30 = const Color(0x4D25674D);
  late Color onbackground90 = const Color(0xE61A1C1B);
  late Color accent50 = const Color(0x80F87849);
  late Color secondarytext50 = const Color(0x8056605B);
  late Color onprimary15 = const Color(0x26FFFFFF);
  late Color onprimary10 = const Color(0x1AFFFFFF);
  late Color warning10 = const Color(0x1AFFB300);
  late Color primary10 = const Color(0x1A14583D);
  late Color primarytext80 = const Color(0xCC1A1C1B);
  late Color onbackground80 = const Color(0xCC1A1C1B);
  late Color info10 = const Color(0x1A4A8D72);
}

abstract class Typography {
  String get displayLargeFamily;
  bool get displayLargeIsCustom;
  TextStyle get displayLarge;
  String get displayMediumFamily;
  bool get displayMediumIsCustom;
  TextStyle get displayMedium;
  String get displaySmallFamily;
  bool get displaySmallIsCustom;
  TextStyle get displaySmall;
  String get headlineLargeFamily;
  bool get headlineLargeIsCustom;
  TextStyle get headlineLarge;
  String get headlineMediumFamily;
  bool get headlineMediumIsCustom;
  TextStyle get headlineMedium;
  String get headlineSmallFamily;
  bool get headlineSmallIsCustom;
  TextStyle get headlineSmall;
  String get titleLargeFamily;
  bool get titleLargeIsCustom;
  TextStyle get titleLarge;
  String get titleMediumFamily;
  bool get titleMediumIsCustom;
  TextStyle get titleMedium;
  String get titleSmallFamily;
  bool get titleSmallIsCustom;
  TextStyle get titleSmall;
  String get labelLargeFamily;
  bool get labelLargeIsCustom;
  TextStyle get labelLarge;
  String get labelMediumFamily;
  bool get labelMediumIsCustom;
  TextStyle get labelMedium;
  String get labelSmallFamily;
  bool get labelSmallIsCustom;
  TextStyle get labelSmall;
  String get bodyLargeFamily;
  bool get bodyLargeIsCustom;
  TextStyle get bodyLarge;
  String get bodyMediumFamily;
  bool get bodyMediumIsCustom;
  TextStyle get bodyMedium;
  String get bodySmallFamily;
  bool get bodySmallIsCustom;
  TextStyle get bodySmall;
}

class ThemeTypography extends Typography {
  ThemeTypography(this.theme);

  final FlutterFlowTheme theme;

  String get displayLargeFamily => 'Outfit';
  bool get displayLargeIsCustom => false;
  TextStyle get displayLarge => GoogleFonts.outfit(
        color: theme.primaryText,
        fontWeight: FontWeight.bold,
        fontSize: 57.0,
        height: 1.1,
      );
  String get displayMediumFamily => 'Outfit';
  bool get displayMediumIsCustom => false;
  TextStyle get displayMedium => GoogleFonts.outfit(
        color: theme.primaryText,
        fontWeight: FontWeight.bold,
        fontSize: 45.0,
        height: 1.15,
      );
  String get displaySmallFamily => 'Outfit';
  bool get displaySmallIsCustom => false;
  TextStyle get displaySmall => GoogleFonts.outfit(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 36.0,
        height: 1.2,
      );
  String get headlineLargeFamily => 'Outfit';
  bool get headlineLargeIsCustom => false;
  TextStyle get headlineLarge => GoogleFonts.outfit(
        color: theme.primaryText,
        fontWeight: FontWeight.bold,
        fontSize: 32.0,
        height: 1.25,
      );
  String get headlineMediumFamily => 'Outfit';
  bool get headlineMediumIsCustom => false;
  TextStyle get headlineMedium => GoogleFonts.outfit(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 28.0,
        height: 1.3,
      );
  String get headlineSmallFamily => 'Outfit';
  bool get headlineSmallIsCustom => false;
  TextStyle get headlineSmall => GoogleFonts.outfit(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 24.0,
        height: 1.35,
      );
  String get titleLargeFamily => 'Outfit';
  bool get titleLargeIsCustom => false;
  TextStyle get titleLarge => GoogleFonts.outfit(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 20.0,
        height: 1.4,
      );
  String get titleMediumFamily => 'Outfit';
  bool get titleMediumIsCustom => false;
  TextStyle get titleMedium => GoogleFonts.outfit(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 16.0,
        height: 1.45,
      );
  String get titleSmallFamily => 'Outfit';
  bool get titleSmallIsCustom => false;
  TextStyle get titleSmall => GoogleFonts.outfit(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 14.0,
        height: 1.5,
      );
  String get labelLargeFamily => 'Outfit';
  bool get labelLargeIsCustom => false;
  TextStyle get labelLarge => GoogleFonts.outfit(
        color: theme.secondaryText,
        fontWeight: FontWeight.w600,
        fontSize: 14.0,
        height: 1.4,
      );
  String get labelMediumFamily => 'Outfit';
  bool get labelMediumIsCustom => false;
  TextStyle get labelMedium => GoogleFonts.outfit(
        color: theme.secondaryText,
        fontWeight: FontWeight.w600,
        fontSize: 12.0,
        height: 1.4,
      );
  String get labelSmallFamily => 'Outfit';
  bool get labelSmallIsCustom => false;
  TextStyle get labelSmall => GoogleFonts.outfit(
        color: theme.secondaryText,
        fontWeight: FontWeight.w600,
        fontSize: 11.0,
        height: 1.3,
      );
  String get bodyLargeFamily => 'Outfit';
  bool get bodyLargeIsCustom => false;
  TextStyle get bodyLarge => GoogleFonts.outfit(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 16.0,
        height: 1.5,
      );
  String get bodyMediumFamily => 'Outfit';
  bool get bodyMediumIsCustom => false;
  TextStyle get bodyMedium => GoogleFonts.outfit(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 14.0,
        height: 1.5,
      );
  String get bodySmallFamily => 'Outfit';
  bool get bodySmallIsCustom => false;
  TextStyle get bodySmall => GoogleFonts.outfit(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 12.0,
        height: 1.5,
      );
}

class DarkModeTheme extends FlutterFlowTheme {
  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color primary = const Color(0xFF4A8D72);
  late Color secondary = const Color(0xFF81B2A3);
  late Color tertiary = const Color(0xFFFF8D63);
  late Color alternate = const Color(0xFF2E3E38);
  late Color primaryText = const Color(0xFFE8EFEF);
  late Color secondaryText = const Color(0xFFB0B8B4);
  late Color primaryBackground = const Color(0xFF0B1410);
  late Color secondaryBackground = const Color(0xFF1D2D26);
  late Color accent1 = const Color(0xFFF4A261);
  late Color accent2 = const Color(0x4D39D2C0);
  late Color accent3 = const Color(0xFF606864);
  late Color accent4 = const Color(0xB2262D34);
  late Color success = const Color(0xFF3F6446);
  late Color warning = const Color(0xFFFFCC40);
  late Color error = const Color(0xFFD6644A);
  late Color info = const Color(0xFF5B8E7B);

  late Color black30 = const Color(0xFF8298B5);
  late Color black20 = const Color(0xFF5CCBDF);
  late Color accent5 = const Color(0x34D2C239);
  late Color lightGray = const Color(0xFFE304FF);
  late Color shadowColor = const Color(0xFF4ED7A6);
  late Color borderColor = const Color(0xFFBC0B96);
  late Color grey = const Color(0xFF3854A7);
  late Color customColor1 = const Color(0xFF57DD18);
  late Color hint = const Color(0xFF64748B);
  late Color divider = const Color(0xFF334155);
  late Color onPrimary = const Color(0xFFFFFFFF);
  late Color primaryContainer = const Color(0x244A8D72);
  late Color onPrimaryContainer = const Color(0xFFE8EFEF);
  late Color onSecondary = const Color(0xFFFFFFFF);
  late Color secondaryContainer = const Color(0x2481B2A3);
  late Color onSecondaryContainer = const Color(0xFFE8EFEF);
  late Color onAccent = const Color(0xFFFFFFFF);
  late Color accentContainer = const Color(0x24FF8D63);
  late Color onAccentContainer = const Color(0xFFE8EFEF);
  late Color onBackground = const Color(0xFFE8EFEF);
  late Color onSurface = const Color(0xFFE8EFEF);
  late Color surfaceVariant = const Color(0xFF283832);
  late Color onSurfaceVariant = const Color(0xFFB0B8B4);
  late Color onSuccess = const Color(0xFFFFFFFF);
  late Color onWarning = const Color(0xFF000000);
  late Color onError = const Color(0xFFFFFFFF);
  late Color onInfo = const Color(0xFFFFFFFF);
  late Color transparent = const Color(0x00000000);
  late Color fullContrast = const Color(0xFFFFFFFF);
  late Color surface20 = const Color(0x331D2D26);
  late Color onPrimary90 = const Color(0xE6FFFFFF);
  late Color secondaryText40 = const Color(0x66B0B8B4);
  late Color onprimary5 = const Color(0x0DFFFFFF);
  late Color onPrimary20 = const Color(0x33FFFFFF);
  late Color onWarning13 = const Color(0x21000000);
  late Color surface15 = const Color(0x261D2D26);
  late Color onSurface80 = const Color(0xCCE8EFEF);
  late Color onPrimary70 = const Color(0xB3FFFFFF);
  late Color onWarning20 = const Color(0x33000000);
  late Color surface10 = const Color(0x1A1D2D26);
  late Color onsurface90 = const Color(0xE6E8EFEF);
  late Color onsurface70 = const Color(0xB3E8EFEF);
  late Color onprimary80 = const Color(0xCCFFFFFF);
  late Color error10 = const Color(0x1AD6644A);
  late Color success10 = const Color(0x1A3F6446);
  late Color error30 = const Color(0x4DD6644A);
  late Color success30 = const Color(0x4D3F6446);
  late Color onbackground90 = const Color(0xE6E8EFEF);
  late Color accent50 = const Color(0x80FF8D63);
  late Color secondarytext50 = const Color(0x80B0B8B4);
  late Color onprimary15 = const Color(0x26FFFFFF);
  late Color onprimary10 = const Color(0x1AFFFFFF);
  late Color warning10 = const Color(0x1AFFCC40);
  late Color primary10 = const Color(0x1A4A8D72);
  late Color primarytext80 = const Color(0xCCE8EFEF);
  late Color onbackground80 = const Color(0xCCE8EFEF);
  late Color info10 = const Color(0x1A5B8E7B);
}

class FFDesignTokens {
  const FFDesignTokens(this.theme);
  final FlutterFlowTheme theme;
  FFSpacing get spacing => const FFSpacing();
  FFRadius get radius => const FFRadius();
  FFShadows get shadow => FFShadows(theme);
}

class FFSpacing {
  const FFSpacing();
  double get none => 0.0;
  double get xs => 4.0;
  double get sm => 8.0;
  double get md => 16.0;
  double get lg => 24.0;
  double get xl => 32.0;
  double get xxl => 48.0;
  double get xxxl => 64.0;
}

class FFRadius {
  const FFRadius();
  double get none => 0.0;
  double get xs => 4.0;
  double get sm => 8.0;
  double get md => 16.0;
  double get lg => 24.0;
  double get xl => 32.0;
  double get xxl => 48.0;
  double get full => 9999.0;
}

class FFShadows {
  const FFShadows(this.theme);
  final FlutterFlowTheme theme;
  BoxShadow get none => const BoxShadow(
      blurRadius: 0.0,
      color: const Color(0x00000000),
      offset: const Offset(0.0, 0.0),
      spreadRadius: 0.0);
  BoxShadow get xs => const BoxShadow(
      blurRadius: 2.0,
      color: const Color(0x1414583D),
      offset: const Offset(0.0, 1.0),
      spreadRadius: 0.0);
  BoxShadow get sm => const BoxShadow(
      blurRadius: 4.0,
      color: const Color(0x1A14583D),
      offset: const Offset(0.0, 2.0),
      spreadRadius: 0.0);
  BoxShadow get md => const BoxShadow(
      blurRadius: 8.0,
      color: const Color(0x2014583D),
      offset: const Offset(0.0, 4.0),
      spreadRadius: 0.0);
  BoxShadow get lg => const BoxShadow(
      blurRadius: 16.0,
      color: const Color(0x2614583D),
      offset: const Offset(0.0, 8.0),
      spreadRadius: 0.0);
  BoxShadow get xl => const BoxShadow(
      blurRadius: 24.0,
      color: const Color(0x2E14583D),
      offset: const Offset(0.0, 12.0),
      spreadRadius: 0.0);
  BoxShadow get xxl => const BoxShadow(
      blurRadius: 32.0,
      color: const Color(0x3614583D),
      offset: const Offset(0.0, 16.0),
      spreadRadius: 0.0);
}

extension TextStyleHelper on TextStyle {
  TextStyle override({
    TextStyle? font,
    String? fontFamily,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    FontStyle? fontStyle,
    bool useGoogleFonts = false,
    TextDecoration? decoration,
    double? lineHeight,
    List<Shadow>? shadows,
    String? package,
  }) {
    if (useGoogleFonts && fontFamily != null && fontFamily.isNotEmpty) {
      font = GoogleFonts.getFont(fontFamily,
          fontWeight: fontWeight ?? this.fontWeight,
          fontStyle: fontStyle ?? this.fontStyle);
    }

    return font != null
        ? font.copyWith(
            color: color ?? this.color,
            fontSize: fontSize ?? this.fontSize,
            letterSpacing: letterSpacing ?? this.letterSpacing,
            fontWeight: fontWeight ?? this.fontWeight,
            fontStyle: fontStyle ?? this.fontStyle,
            decoration: decoration,
            height: lineHeight,
            shadows: shadows,
          )
        : copyWith(
            fontFamily: fontFamily,
            package: package,
            color: color,
            fontSize: fontSize,
            letterSpacing: letterSpacing,
            fontWeight: fontWeight,
            fontStyle: fontStyle,
            decoration: decoration,
            height: lineHeight,
            shadows: shadows,
          );
  }
}
