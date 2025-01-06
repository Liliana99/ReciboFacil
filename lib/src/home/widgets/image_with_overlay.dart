import 'package:flutter/material.dart';

class ImageWithRedOverlay extends StatelessWidget {
  final String baseImagePath; // Ruta de la imagen base
  final String overlayImagePath; // Ruta de la "X" roja

  const ImageWithRedOverlay({
    Key? key,
    required this.baseImagePath,
    required this.overlayImagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center, // Centra la "X" sobre la imagen base
      children: [
        // Imagen base
        Image.asset(
          baseImagePath,
          width: 35,
          height: 35,
          fit: BoxFit.contain,
        ),
        Icon(
          Icons.close_outlined,
          color: Colors.white,
          size: 30,
        )
        // Imagen de la "X" roja
        // Image.asset(
        //   overlayImagePath,
        //   width: 20, // Ajusta el tamaño de la "X"
        //   height: 20,
        //   color: Colors.white,
        //   fit: BoxFit.contain,
        // ),
      ],
    );
  }
}
