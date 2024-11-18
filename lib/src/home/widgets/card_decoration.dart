import 'package:flutter/material.dart';

final segmentColors = {
  "Horas Valle": {
    "background": Colors.green.withOpacity(0.1), // Fondo verde claro
    "border": Colors.green, // Borde verde
  },
  "Horas Llano": {
    "background": Colors.yellow.withOpacity(0.1), // Fondo amarillo claro
    "border": Colors.yellow, // Borde amarillo
  },
  "Horas Punta": {
    "background": Colors.red.withOpacity(0.1), // Fondo rojo claro
    "border": Colors.red, // Borde rojo
  },
  "default": {
    "background": Colors.grey.withOpacity(0.1), // Fondo gris claro
    "border": Colors.grey, // Borde gris
  },
};

class CardContainer extends StatelessWidget {
  final Widget childText;
  final String segmentTime;

  const CardContainer(
      {super.key, required this.childText, required this.segmentTime});

  @override
  Widget build(BuildContext context) {
    // Seleccionar colores según el segmento recibido
    final colors = segmentColors[segmentTime] ?? segmentColors["default"]!;

    return Container(
      width: 300,
      height: 150,
      decoration: BoxDecoration(
        color: colors["background"],
        borderRadius: BorderRadius.circular(15), // Esquinas redondeadas
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Sombra suave
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // Posición de la sombra
          ),
        ],
        border: Border.all(
          color: colors["border"]!, // Borde opcional
          width: 1,
        ),
      ),
      child: childText,
    );
  }
}
