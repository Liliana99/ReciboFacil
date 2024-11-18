import 'package:flutter/material.dart';

extension EmptySpace on num {
  SizedBox get ht => SizedBox(height: toDouble());
  SizedBox get wd => SizedBox(width: toDouble());

  SizedBox htFactor(Size size) => SizedBox(height: size.height * toDouble());

  SizedBox wdFactor(Size size) => SizedBox(width: size.width * toDouble());
}
