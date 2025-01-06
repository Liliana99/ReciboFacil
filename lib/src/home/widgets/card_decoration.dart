import 'package:flutter/material.dart';

final segmentColors = {
  "Horas Valle": {
    "background": Colors.green.withOpacity(0.1), // Fondo verde claro
    "border": Colors.green, // Borde verde
  },
  "Horas Llano": {
    "background": Colors.orange.withOpacity(0.1), // Fondo naranja claro
    "border": Colors.orange, // Borde amarillo
  },
  "Horas Punta": {
    "background": Colors.red.withOpacity(0.1), // Fondo rojo
    "border": Colors.red, // Borde rojo
  },
  "default": {
    "background": Colors.grey.withOpacity(0.1), // Fondo gris claro
    "border": Colors.grey, // Borde gris
  },
};

class CardContainer extends StatefulWidget {
  final Widget childText;
  final String segmentTime;

  const CardContainer(
      {super.key, required this.childText, required this.segmentTime});

  @override
  State<CardContainer> createState() => _CardContainerState();
}

class _CardContainerState extends State<CardContainer> {
  @override
  Widget build(BuildContext context) {
    // Seleccionar colores según el segmento recibido
    final colors =
        segmentColors[widget.segmentTime] ?? segmentColors["default"]!;

    return Container(
      width: 300,
      height: 150,
      decoration: BoxDecoration(
        color: colors["background"]!.withValues(alpha: 0.7),
        // borderRadius: BorderRadius.circular(15), // Esquinas redondeadas
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.5), // Sombra suave
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
      child: widget.childText,
    );
  }
}

class CardDecoration extends StatelessWidget {
  const CardDecoration({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25), // Esquinas redondeadas
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.5), // Sombra suave
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // Posición de la sombra
          ),
        ],
        border: Border.all(
          color: Colors.black54, // Borde opcional
          width: 1,
        ),
      ),
      child: child,
    );
  }
}
