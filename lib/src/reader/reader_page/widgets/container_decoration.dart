import 'package:flutter/material.dart';
import 'package:recibo_facil/const/colors_constants.dart';

class RoundedTopContainer extends StatelessWidget {
  final Widget child;
  final Color? color;

  const RoundedTopContainer({
    final Key? key,
    required this.child,
    this.color = const Color.fromARGB(255, 5, 5, 5),
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
            color: ColorsApp.baseColorNegro.withValues(alpha: 0.02),
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

class ModalDecorationLine extends StatelessWidget {
  const ModalDecorationLine({super.key});

  @override
  Widget build(final BuildContext context) {
    return Container(
      width: 70,
      height: 4,
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      decoration: BoxDecoration(
          color: ColorsApp.baseColorApp,
          borderRadius: BorderRadius.circular(2)),
    );
  }
}
