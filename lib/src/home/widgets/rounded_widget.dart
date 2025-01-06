import 'package:flutter/material.dart';

class RoundedImageWidget extends StatelessWidget {
  final Color backgroundColor;
  final String assetImagePath;

  const RoundedImageWidget({
    Key? key,
    required this.backgroundColor,
    required this.assetImagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.3),
        shape: BoxShape.circle,
        border: Border.all(
          color: backgroundColor.withOpacity(0.8),
        ),
      ),
      child: Center(
        child: Image.asset(
          assetImagePath,

          fit: BoxFit.cover, // Ajusta la imagen para cubrir el círculo
        ),
      ),
    );
  }
}
