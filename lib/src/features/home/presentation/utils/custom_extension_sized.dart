import 'package:flutter/material.dart';

extension EmptySpace on num {
  SizedBox get ht => SizedBox(height: toDouble());
  SizedBox get wd => SizedBox(width: toDouble());

  SizedBox htRelative(Size size) => SizedBox(height: size.height * toDouble());

  SizedBox wdRelative(Size size) => SizedBox(width: size.width * toDouble());
}
