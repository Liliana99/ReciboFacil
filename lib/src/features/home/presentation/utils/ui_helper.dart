import 'package:flutter/material.dart';

TextStyle getResponsiveTextStyle(
    BuildContext context, TextStyle smallStyle, TextStyle largeStyle) {
  return MediaQuery.of(context).size.width < 600 ? smallStyle : largeStyle;
}
