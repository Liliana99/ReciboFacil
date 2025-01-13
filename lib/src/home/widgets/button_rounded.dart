import 'package:flutter/material.dart';
import 'package:recibo_facil/const/colors_constants.dart';

class ButtonRounded extends StatelessWidget {
  const ButtonRounded({
    super.key,
    this.iconPath,
    required this.width,
    required this.height,
    required this.onPressed,
    this.icon,
  });
  final String? iconPath;
  final Icon? icon;
  final double width;
  final double height;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 46, 82, 225),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: iconPath != null
              ? Image.asset(
                  iconPath!,
                  color: Colors.white,
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                )
              : icon,
        ),
      ),
    );
  }
}
