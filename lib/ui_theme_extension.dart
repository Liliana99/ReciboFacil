import 'package:flutter/material.dart';

extension UIThemeExtension on BuildContext {
  // Estilos de texto de Material 3
  TextStyle? get dispL => Theme.of(this).textTheme.displayLarge;
  TextStyle? get dispM => Theme.of(this).textTheme.displayMedium;
  TextStyle? get dispS => Theme.of(this).textTheme.displaySmall;

  TextStyle? get headL => Theme.of(this).textTheme.headlineLarge;
  TextStyle? get headM => Theme.of(this).textTheme.headlineMedium;
  TextStyle? get headS => Theme.of(this).textTheme.headlineSmall;

  TextStyle? get bodyL => Theme.of(this).textTheme.bodyLarge;
  TextStyle? get bodyM => Theme.of(this).textTheme.bodyMedium;
  TextStyle? get bodyS => Theme.of(this).textTheme.bodySmall;

  TextStyle? get labelL => Theme.of(this).textTheme.labelLarge;
  TextStyle? get labelM => Theme.of(this).textTheme.labelMedium;
  TextStyle? get labelS => Theme.of(this).textTheme.labelSmall;
}
