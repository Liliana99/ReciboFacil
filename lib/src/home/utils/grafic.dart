import 'package:flutter/material.dart';
import 'package:recibo_facil/src/home/models/precios_api.dart';

class PrecioLuzPainter extends CustomPainter {
  PrecioLuzPainter({
    required this.preciosPorHora,
    required this.horaActual,
  });

  final List<PrecioHora> preciosPorHora;
  final int horaActual;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final anchoBarra = size.width / preciosPorHora.length;

    for (int i = 0; i < preciosPorHora.length; i++) {
      final xInicio = i * anchoBarra;
      final xFin = xInicio + anchoBarra;

      // Color según el rango
      paint.color = _obtenerColor(preciosPorHora[i].precio);

      canvas.drawRect(
        Rect.fromLTRB(xInicio, 0, xFin,
            size.height - 20), // Ajustar para dejar espacio a las etiquetas
        paint,
      );
    }

    // Dibujar la línea negra en la hora actual
    final posicionHoraActual = horaActual * anchoBarra;
    final lineaNegra = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0;

    canvas.drawLine(
      Offset(posicionHoraActual, 0),
      Offset(posicionHoraActual,
          size.height - 20), // Ajustar para no chocar con etiquetas
      lineaNegra,
    );

    // Dibujar la hora encima de la línea negra
    final textPainterHoraActual = TextPainter(
      text: TextSpan(
        text: '${horaActual}h', // Mostrar hora actual
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainterHoraActual.layout();
    final textXHoraActual =
        posicionHoraActual - (textPainterHoraActual.width / 2);
    double textYHoraActual = -15; // Ajustar la posición vertical del texto
    textPainterHoraActual.paint(
        canvas, Offset(textXHoraActual, textYHoraActual));

    // Dibujar las etiquetas de inicio (01h) y final (24h)
    final textPainterInicio = TextPainter(
      text: const TextSpan(
        text: '01h',
        style: TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainterInicio.layout();
    textPainterInicio.paint(canvas, Offset(0, size.height - 15));

    final textPainterFin = TextPainter(
      text: const TextSpan(
        text: '24h',
        style: TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainterFin.layout();
    textPainterFin.paint(
        canvas, Offset(size.width - textPainterFin.width, size.height - 15));
  }

  Color _obtenerColor(double precio) {
    if (precio < 0.20) {
      return Colors.green;
    } else if (precio >= 0.20 && precio < 0.25) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
