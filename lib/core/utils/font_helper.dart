import 'package:flutter/material.dart';

class FontHelper {
  static const String poppinsFontFamily = 'Poppins';

  static TextStyle poppins({
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Color? color,
    Color? backgroundColor,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
    String? debugLabel,
    String? fontFamilyFallback,
    String? package,
  }) {
    return TextStyle(
      fontFamily: poppinsFontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      color: color,
      backgroundColor: backgroundColor,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      debugLabel: debugLabel,
      fontFamilyFallback: fontFamilyFallback != null ? [fontFamilyFallback] : null,
      package: package,
    );
  }

  static String? get poppinsFontFamilyName => poppinsFontFamily;
}
