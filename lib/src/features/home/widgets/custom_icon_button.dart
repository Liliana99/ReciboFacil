import 'package:flutter/material.dart';
import 'package:recibo_facil/const/colors_constants.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton(
      {super.key, required this.icon, required this.onPressed});
  final Widget icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: ColorsApp.baseColorApp,
          ),
          child: icon),
    );
  }
}
