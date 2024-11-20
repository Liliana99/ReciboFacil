import 'package:flutter/material.dart';
import 'package:recibo_facil/src/home/pages/home_page_reader.dart';

class InfoCardContainer extends StatelessWidget {
  final Size size;
  final bool isMultiline;
  final Widget icon;
  final String label;
  final String value;
  final Color color;

  const InfoCardContainer({
    required this.size,
    required this.isMultiline,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width * 0.40,
      height: isMultiline ? size.height * 0.30 : size.height * 0.20,
      child: InfoCard(
        icon: icon,
        label: label,
        value: value,
        color: color,
      ),
    );
  }
}
