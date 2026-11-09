import 'package:dashink/core/init/app_init.dart';
import 'package:dashink/core/theme/app_text_styles.dart';
import 'package:dashink/generated/colors.gen.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    scaffoldBackgroundColor: ColorName.paper,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: ColorName.tomato,
      onPrimary: ColorName.white,
      secondary: ColorName.mint,
      onSecondary: ColorName.white,
      surface: ColorName.paperCard,
      onSurface: ColorName.ink,
      error: ColorName.tomato,
      onError: ColorName.white,
    ),
    textTheme: TextTheme(
      bodyMedium: AppTextStyles.bodyMedium,
      labelLarge: AppTextStyles.rowLabel,
    ).apply(bodyColor: ColorName.ink, displayColor: ColorName.ink),
    dividerColor: ColorName.paperLine,
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: AppInit.systemUiOverlayStyle,
    ),
  );
}
