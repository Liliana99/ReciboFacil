import 'package:flutter/material.dart';
import 'package:recibo_facil/const/colors_constants.dart';

class RoundedTopContainer extends StatelessWidget {
  final Widget child;
  final Color? color;

  const RoundedTopContainer({
    final Key? key,
    required this.child,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
        boxShadow: [
          BoxShadow(
            color: ColorsApp.baseColorApp.withValues(alpha: 0.05),
            blurRadius: 10.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: child,
    );
  }
}
