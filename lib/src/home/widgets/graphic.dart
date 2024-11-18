import 'dart:math';

import 'package:flutter/material.dart';
import 'package:recibo_facil/src/home/widgets/advice.dart';

class GraphicCustom extends StatefulWidget {
  const GraphicCustom({
    super.key,
  });

  @override
  State<GraphicCustom> createState() => _GraphicCustomState();
}

class _GraphicCustomState extends State<GraphicCustom> {
  bool isHightSectionVisible = false;
  bool isNightSectionVisible = false;
  bool isOffPeakSctionVisible = false;
  bool isTipVisible = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildClockSection(context),
          if (isHightSectionVisible &&
              isNightSectionVisible &&
              isOffPeakSctionVisible)
            SizedBox(height: 100),
          if (isTipVisible)
            SizedBox(
              height: 70,
            ),
          _buildEnergyTipsSection(), // Sección de consejos energéticos
          SizedBox(height: 50),
          if (!isHightSectionVisible &&
              !isNightSectionVisible &&
              !isOffPeakSctionVisible)
            EnergyAdviceScreen()
        ],
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildInfoBox("Total a Pagar", "50€",
              Icon(Icons.euro, color: Colors.blueAccent, size: 30)),
          _buildInfoBox(
            "Mes Facturado",
            "Octubre 2024",
            Image.asset(
              'assets/iconos/calendar.png',
              width: 30,
              height: 30,
              color: Colors.blueAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String title, String value, Widget icon) {
    return Column(
      children: [
        icon,
        SizedBox(height: 4),
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        Text(
          value,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildClockSection(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onDoubleTap: () {
              setState(() {
                isNightSectionVisible = false;
                isHightSectionVisible = false;
                isOffPeakSctionVisible = false;
                isTipVisible = false;
              });
            },
            onTapUp: (details) {
              // Obtener la posición del toque relativa al centro del CustomPaint
              RenderBox box = context.findRenderObject() as RenderBox;
              Offset localPosition = box.globalToLocal(details.globalPosition);
              Offset center = Offset(box.size.width / 2, box.size.height / 2);

              double dx = localPosition.dx - center.dx;
              double dy = localPosition.dy - center.dy;
              double angle = (atan2(dy, dx) * 180 / pi + 360) % 360;

              setState(() {
                isTipVisible = true;
              });

              if (angle >= 0 && angle < 120) {
                print('Horas Nocturnas');
                setState(() {
                  isNightSectionVisible = true;
                  isHightSectionVisible = false;
                  isOffPeakSctionVisible = false;
                });
              } else if (angle >= 120 && angle < 240) {
                print('Horas Valle');
                setState(() {
                  isNightSectionVisible = false;
                  isHightSectionVisible = false;
                  isOffPeakSctionVisible = true;
                });
              } else if (angle >= 240 && angle < 360) {
                _buildEnergyTip("Evitar electrodomésticos grandes",
                    Icons.warning_amber_rounded, Colors.orange);
                setState(() {
                  isNightSectionVisible = false;
                  isHightSectionVisible = true;
                  isOffPeakSctionVisible = false;
                });
              }
            },
            child: CustomPaint(
              size: Size(300, 300),
              painter: ClockPainterWithSections(currentTime: DateTime.now()),
            ),
          ),
          // Texto central
          // Center(child: widget.clock),

          // Positioned(
          //   top: 20,
          //   right: 02,
          //   child: Column(
          //     children: [
          //       Text(
          //         "Horas Punta",
          //         style: TextStyle(
          //             color: Colors.black, fontWeight: FontWeight.bold),
          //       ),
          //       SizedBox(height: 4),
          //       Icon(Icons.wb_sunny,
          //           color: const Color.fromARGB(255, 234, 141, 125), size: 30),
          //     ],
          //   ),
          // ),
          // // Texto "Horas Valle" en la sección azul
          // Positioned(
          //   left: 10,
          //   top: 30,
          //   child: Column(
          //     children: [
          //       Text(
          //         "Horas Valle",
          //         style: TextStyle(
          //             color: Colors.black, fontWeight: FontWeight.bold),
          //       ),
          //       SizedBox(height: 4),
          //       Icon(Icons.cloud,
          //           color: const Color.fromARGB(255, 218, 228, 142), size: 30),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildHourIndicator(String label, Color color) {
    return Column(
      children: [
        Icon(Icons.access_time, color: color),
        Text(label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildEnergyTipsSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        if (isHightSectionVisible)
          _buildEnergyTip("Evitar electrodomésticos grandes",
              Icons.warning_amber_rounded, Colors.orange),
        if (isOffPeakSctionVisible)
          _buildEnergyTip(
              "Aprovechar para cocinar", Icons.kitchen, Colors.black),
        if (isNightSectionVisible)
          _buildEnergyTip(
              "Usar luces de bajo consumo", Icons.lightbulb, Colors.lightBlue),
      ],
    );
  }

  Widget _buildEnergyTip(String text, IconData icon, Color color) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            SizedBox(width: 8),
            Text(
              text,
              textAlign: TextAlign.left,
              maxLines: 2,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    final sections = [
      {
        "color": Colors.green, // Valle
        "startAngle": -90.0, // 0:00
        "sweepAngle": 120.0, // Hasta 8:00
        "label": "Horas Valle\n(0:00-8:00)",
        "labelAngle": -30.0, // Etiqueta a 4:00
      },
      {
        "color": Colors.yellow, // Llano
        "startAngle": 30.0, // 8:00
        "sweepAngle": 30.0, // Hasta 10:00
        "label": "Horas Llano\n(8:00-10:00)",
        "labelAngle": 45.0, // Etiqueta a 9:00
      },
      {
        "color": Colors.red, // Punta
        "startAngle": 60.0, // 10:00
        "sweepAngle": 60.0, // Hasta 14:00
        "label": "Horas Punta\n(10:00-14:00)",
        "labelAngle": 90.0, // Etiqueta a 12:00
      },
      {
        "color": Colors.yellow, // Llano
        "startAngle": 120.0, // 14:00
        "sweepAngle": 90.0, // Hasta 18:00
        "label": "Horas Llano\n(14:00-18:00)",
        "labelAngle": 225.0, // Etiqueta a 15:00
      },
      {
        "color": Colors.red, // Punta
        "startAngle": 210.0, // 18:00
        "sweepAngle": 60.0, // Hasta 22:00
        "label": "Horas Punta\n(18:00-22:00)",
        "labelAngle": 270.0, // Etiqueta a 18:00
      },
      {
        "color": Colors.yellow, // Llano
        "startAngle": 270.0, // 22:00
        "sweepAngle": 90.0, // Hasta 0:00
        "label": "Horas Llano\n(22:00-0:00)",
        "labelAngle": 345.0, // Etiqueta a 23:00
      },
    ];

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (var section in sections) {
      paint.color = section["color"] as Color;

      double startAngle = (section["startAngle"] as double) * pi / 180;
      double sweepAngle = (section["sweepAngle"] as double) * pi / 180;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Etiquetas
      final labelAngle = (section["labelAngle"] as double) * pi / 180;
      final textOffset = Offset(
        center.dx + radius * 0.85 * cos(labelAngle),
        center.dy + radius * 0.85 * sin(labelAngle),
      );

      textPainter.text = TextSpan(
        text: section["label"] as String,
        style: const TextStyle(fontSize: 12, color: Colors.black),
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          textOffset.dx - textPainter.width / 2,
          textOffset.dy - textPainter.height / 2,
        ),
      );
    }

    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.6, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class ClockWithLabels extends StatelessWidget {
  final DateTime currentTime;

  ClockWithLabels({required this.currentTime});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        size: const Size(300, 300), // Tamaño del reloj
        painter: ClockPainterWithExternalLabels(currentTime: currentTime),
      ),
    );
  }
}

class ClockPainterWithSections extends CustomPainter {
  final DateTime currentTime;

  ClockPainterWithSections({required this.currentTime});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Definir franjas horarias con colores y ángulos corregidos
    final sections = [
      {
        "color": Colors.green,
        "startAngle": -90.0, // Comienza a las 0:00 (parte superior)
        "sweepAngle": 120.0, // 120 grados (de 0:00 a 8:00)
        "label": "Valle"
      },
      {
        "color": Colors.yellow,
        "startAngle": 30.0, // Comienza a las 8:00
        "sweepAngle": 30.0, // 30 grados (de 8:00 a 10:00)
        "label": "Llano"
      },
      {
        "color": Colors.red,
        "startAngle": 60.0, // Comienza a las 10:00
        "sweepAngle": 60.0, // 60 grados (de 10:00 a 14:00)
        "label": "Punta"
      },
      {
        "color": Colors.yellow,
        "startAngle": 120.0, // Comienza a las 14:00
        "sweepAngle": 90.0, // 90 grados (de 14:00 a 20:00)
        "label": "Llano"
      },
      {
        "color": Colors.red,
        "startAngle": 210.0, // Comienza a las 20:00
        "sweepAngle": 30.0, // 30 grados (de 20:00 a 22:00)
        "label": "Punta"
      },
      {
        "color": Colors.yellow,
        "startAngle": 240.0, // Comienza a las 22:00
        "sweepAngle": 30.0, // 30 grados (de 22:00 a 0:00)
        "label": "Llano"
      },
    ];

    // Dibujar franjas horarias
    for (var section in sections) {
      paint.color = section["color"] as Color;
      double startAngle = (section["startAngle"] as double) * pi / 180;
      double sweepAngle = (section["sweepAngle"] as double) * pi / 180;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Dibujar etiquetas de franjas horarias
      double midAngle = ((section["startAngle"] as double) +
              ((section["sweepAngle"] as double) / 2))
          .toDouble();
      final labelAngle = midAngle * pi / 180;

      final labelOffset = Offset(
        center.dx +
            radius *
                0.7 *
                cos(labelAngle), // Cambiado a 0.7 para mejor visibilidad
        center.dy + radius * 0.7 * sin(labelAngle),
      );

      final textPainter = TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: section["label"] as String,
          style: const TextStyle(
              fontSize: 12,
              color: Color.fromARGB(255, 253, 252, 252),
              fontWeight: FontWeight.bold),
        ),
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(labelOffset.dx - textPainter.width / 4,
            labelOffset.dy - textPainter.height / 2),
      );
    }

    // Dibujar números del reloj (0-23)
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < 24; i++) {
      final angle =
          (i * 15 - 90) * pi / 180; // Asegura que 0 esté en la parte superior
      final numberOffset = Offset(
        center.dx + radius * 0.85 * cos(angle),
        center.dy + radius * 0.85 * sin(angle),
      );

      textPainter.text = TextSpan(
        text: '$i', // Mostrar los números del 0 al 23
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black), // Números de color negro
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          numberOffset.dx - textPainter.width / 2,
          numberOffset.dy - textPainter.height / 2,
        ),
      );
    }

    // Dibujar reloj interno (agujas)
    final hourAngle = ((currentTime.hour % 24) + currentTime.minute / 60) * 15;
    final minuteAngle = currentTime.minute * 6;

    // Aguja de la hora
    paint.color = Colors.black;
    paint.strokeWidth = 4;
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * 0.5 * cos((hourAngle - 90) * pi / 180),
        center.dy + radius * 0.5 * sin((hourAngle - 90) * pi / 180),
      ),
      paint,
    );

    // Aguja del minuto
    paint.color = Colors.blue;
    paint.strokeWidth = 2;
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * 0.7 * cos((minuteAngle - 90) * pi / 180),
        center.dy + radius * 0.7 * sin((minuteAngle - 90) * pi / 180),
      ),
      paint,
    );

    // ** Círculo interno blanco **
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.1, paint);

    // ** Círculo central negro pequeño para darle un toque de elegancia **
    paint.color = Colors.black;
    canvas.drawCircle(center, radius * 0.03, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ClockPainterWithExternalLabels extends CustomPainter {
  final DateTime currentTime;

  ClockPainterWithExternalLabels({required this.currentTime});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Secciones de colores y ángulos
    final sections = [
      {
        "color": Colors.green,
        "startAngle": -90.0, // 0:00
        "sweepAngle": 120.0, // Hasta 8:00
        "label": "Horas Valle",
        "time": "0:00-8:00",
      },
      {
        "color": Colors.yellow,
        "startAngle": 30.0, // 8:00
        "sweepAngle": 30.0, // Hasta 10:00
        "label": "Horas Llano",
        "time": "8:00-10:00",
      },
      {
        "color": Colors.red,
        "startAngle": 60.0, // 10:00
        "sweepAngle": 60.0, // Hasta 14:00
        "label": "Horas Punta",
        "time": "10:00-14:00",
      },
      {
        "color": Colors.yellow,
        "startAngle": 120.0, // 14:00
        "sweepAngle": 90.0, // Hasta 18:00
        "label": "Horas Llano",
        "time": "14:00-18:00",
      },
      {
        "color": Colors.red,
        "startAngle": 210.0, // 18:00
        "sweepAngle": 60.0, // Hasta 22:00
        "label": "Horas Punta",
        "time": "18:00-22:00",
      },
      {
        "color": Colors.yellow,
        "startAngle": 270.0, // 22:00
        "sweepAngle": 90.0, // Hasta 0:00
        "label": "Horas Llano",
        "time": "22:00-0:00",
      },
    ];

    // Dibujar secciones del reloj
    for (var section in sections) {
      paint.color = section["color"] as Color;
      double startAngle = (section["startAngle"] as double) * pi / 180;
      double sweepAngle = (section["sweepAngle"] as double) * pi / 180;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
    }

    // Dibujar etiquetas externas
    for (var section in sections) {
      final labelAngle = ((section["startAngle"] as double) +
              (section["sweepAngle"] as double) / 2) *
          pi /
          180;
      final labelOffset = Offset(
        center.dx + radius * 1.2 * cos(labelAngle),
        center.dy + radius * 1.2 * sin(labelAngle),
      );

      final textPainter = TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: "${section["label"]}\n(${section["time"]})",
          style: const TextStyle(fontSize: 12, color: Colors.black),
        ),
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          labelOffset.dx - textPainter.width / 2,
          labelOffset.dy - textPainter.height / 2,
        ),
      );
    }

    // Dibujar números del reloj (0-23)
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < 24; i++) {
      final angle = (i * 15 - 90) * pi / 180;
      final numberOffset = Offset(
        center.dx + radius * 0.85 * cos(angle),
        center.dy + radius * 0.85 * sin(angle),
      );

      textPainter.text = TextSpan(
        text: '$i',
        style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          numberOffset.dx - textPainter.width / 2,
          numberOffset.dy - textPainter.height / 2,
        ),
      );
    }

    // Dibujar reloj interior (manecillas)
    final hourAngle = ((currentTime.hour % 12) + currentTime.minute / 60) * 30;
    final minuteAngle = currentTime.minute * 6;

    // Aguja de la hora
    paint.color = Colors.black;
    paint.strokeWidth = 4;
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * 0.5 * cos((hourAngle - 90) * pi / 180),
        center.dy + radius * 0.5 * sin((hourAngle - 90) * pi / 180),
      ),
      paint,
    );

    // Aguja del minuto
    paint.color = Colors.blue;
    paint.strokeWidth = 2;
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * 0.7 * cos((minuteAngle - 90) * pi / 180),
        center.dy + radius * 0.7 * sin((minuteAngle - 90) * pi / 180),
      ),
      paint,
    );

    // Círculo central
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.1, paint);

    // Círculo central pequeño negro
    paint.color = Colors.black;
    canvas.drawCircle(center, radius * 0.03, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

/** */
class ClockPainterWithInnerClock extends CustomPainter {
  final DateTime currentTime;

  ClockPainterWithInnerClock({required this.currentTime});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Secciones de colores y ángulos
    final sections = [
      {
        "color": Colors.green,
        "startAngle": -90.0, // 0:00
        "sweepAngle": 120.0, // Hasta 8:00
        "label": "Horas Valle\n(0:00-8:00)",
        "labelAngle": -30.0, // Etiqueta a 4:00
      },
      {
        "color": Colors.yellow,
        "startAngle": 30.0, // 8:00
        "sweepAngle": 30.0, // Hasta 10:00
        "label": "Horas Llano\n(8:00-10:00)",
        "labelAngle": 45.0, // Etiqueta a 9:00
      },
      {
        "color": Colors.red,
        "startAngle": 60.0, // 10:00
        "sweepAngle": 60.0, // Hasta 14:00
        "label": "Horas Punta\n(10:00-14:00)",
        "labelAngle": 90.0, // Etiqueta a 12:00
      },
      {
        "color": Colors.yellow,
        "startAngle": 120.0, // 14:00
        "sweepAngle": 90.0, // Hasta 18:00
        "label": "Horas Llano\n(14:00-18:00)",
        "labelAngle": 225.0, // Etiqueta a 15:00
      },
      {
        "color": Colors.red,
        "startAngle": 210.0, // 18:00
        "sweepAngle": 60.0, // Hasta 22:00
        "label": "Horas Punta\n(18:00-22:00)",
        "labelAngle": 270.0, // Etiqueta a 18:00
      },
      {
        "color": Colors.yellow,
        "startAngle": 270.0, // 22:00
        "sweepAngle": 90.0, // Hasta 0:00
        "label": "Horas Llano\n(22:00-0:00)",
        "labelAngle": 345.0, // Etiqueta a 23:00
      },
    ];

    // Dibujar secciones de colores
    for (var section in sections) {
      paint.color = section["color"] as Color;

      double startAngle = (section["startAngle"] as double) * pi / 180;
      double sweepAngle = (section["sweepAngle"] as double) * pi / 180;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Dibujar etiquetas
      final labelAngle = (section["labelAngle"] as double) * pi / 180;
      final textOffset = Offset(
        center.dx + radius * 0.85 * cos(labelAngle),
        center.dy + radius * 0.85 * sin(labelAngle),
      );

      final textPainter = TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: section["label"] as String,
          style: const TextStyle(fontSize: 12, color: Colors.black),
        ),
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          textOffset.dx - textPainter.width / 2,
          textOffset.dy - textPainter.height / 2,
        ),
      );
    }

    // Fondo blanco interno
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.6, paint);

    // Dibujar números del reloj (0-23)
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < 24; i++) {
      final angle = (i * 15 - 90) * pi / 180; // Posición del número
      final numberOffset = Offset(
        center.dx + radius * 0.5 * cos(angle),
        center.dy + radius * 0.5 * sin(angle),
      );

      textPainter.text = TextSpan(
        text: '$i',
        style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          numberOffset.dx - textPainter.width / 2,
          numberOffset.dy - textPainter.height / 2,
        ),
      );
    }

    // Dibujar agujas del reloj
    final hourAngle = ((currentTime.hour % 12) + currentTime.minute / 60) * 30;
    final minuteAngle = currentTime.minute * 6;

    // Aguja de la hora
    paint.color = Colors.black;
    paint.strokeWidth = 4;
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * 0.3 * cos((hourAngle - 90) * pi / 180),
        center.dy + radius * 0.3 * sin((hourAngle - 90) * pi / 180),
      ),
      paint,
    );

    // Aguja del minuto
    paint.color = Colors.blue;
    paint.strokeWidth = 2;
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * 0.45 * cos((minuteAngle - 90) * pi / 180),
        center.dy + radius * 0.45 * sin((minuteAngle - 90) * pi / 180),
      ),
      paint,
    );

    // Círculo pequeño negro en el centro
    paint.color = Colors.black;
    canvas.drawCircle(center, radius * 0.02, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

//*/
class ClockPainter12Hours extends CustomPainter {
  final DateTime currentTime;

  ClockPainter12Hours({required this.currentTime});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Secciones de colores y ángulos
    final sections = [
      {
        "color": Colors.green, // Horas Valle
        "startAngle": -90.0, // 12:00
        "sweepAngle": 120.0, // Hasta 4:00
        "label": "Horas Valle\n(12:00-4:00)",
        "labelAngle": -30.0, // Etiqueta entre 2:00 y 3:00
      },
      {
        "color": Colors.yellow, // Horas Llano
        "startAngle": 30.0, // 4:00
        "sweepAngle": 60.0, // Hasta 6:00
        "label": "Horas Llano\n(4:00-6:00)",
        "labelAngle": 45.0, // Etiqueta entre 5:00 y 6:00
      },
      {
        "color": Colors.red, // Horas Punta
        "startAngle": 90.0, // 6:00
        "sweepAngle": 90.0, // Hasta 9:00
        "label": "Horas Punta\n(6:00-9:00)",
        "labelAngle": 135.0, // Etiqueta entre 7:00 y 8:00
      },
      {
        "color": Colors.yellow, // Horas Llano
        "startAngle": 180.0, // 9:00
        "sweepAngle": 60.0, // Hasta 11:00
        "label": "Horas Llano\n(9:00-11:00)",
        "labelAngle": 225.0, // Etiqueta entre 10:00 y 11:00
      },
      {
        "color": Colors.red, // Horas Punta
        "startAngle": 240.0, // 11:00
        "sweepAngle": 30.0, // Hasta 12:00
        "label": "Horas Punta\n(11:00-12:00)",
        "labelAngle": 270.0, // Etiqueta a las 11:30
      },
    ];

    // Dibujar secciones de colores
    for (var section in sections) {
      paint.color = section["color"] as Color;

      double startAngle = (section["startAngle"] as double) * pi / 180;
      double sweepAngle = (section["sweepAngle"] as double) * pi / 180;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Dibujar etiquetas externas
      final labelAngle = (section["labelAngle"] as double) * pi / 180;
      final textOffset = Offset(
        center.dx + radius * 0.85 * cos(labelAngle),
        center.dy + radius * 0.85 * sin(labelAngle),
      );

      final textPainter = TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: section["label"] as String,
          style: const TextStyle(fontSize: 12, color: Colors.black),
        ),
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          textOffset.dx - textPainter.width / 2,
          textOffset.dy - textPainter.height / 2,
        ),
      );
    }

    // Fondo blanco interno
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.6, paint);

    // Dibujar números del reloj (1-12)
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 1; i <= 12; i++) {
      final angle = (i * 30 - 90) * pi / 180; // Posición del número
      final numberOffset = Offset(
        center.dx + radius * 0.5 * cos(angle),
        center.dy + radius * 0.5 * sin(angle),
      );

      textPainter.text = TextSpan(
        text: '$i',
        style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          numberOffset.dx - textPainter.width / 2,
          numberOffset.dy - textPainter.height / 2,
        ),
      );
    }

    // Dibujar agujas del reloj
    final hourAngle = ((currentTime.hour % 12) + currentTime.minute / 60) * 30;
    final minuteAngle = currentTime.minute * 6;

    // Aguja de la hora
    paint.color = Colors.black;
    paint.strokeWidth = 4;
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * 0.3 * cos((hourAngle - 90) * pi / 180),
        center.dy + radius * 0.3 * sin((hourAngle - 90) * pi / 180),
      ),
      paint,
    );

    // Aguja del minuto
    paint.color = Colors.blue;
    paint.strokeWidth = 2;
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * 0.45 * cos((minuteAngle - 90) * pi / 180),
        center.dy + radius * 0.45 * sin((minuteAngle - 90) * pi / 180),
      ),
      paint,
    );

    // Círculo pequeño negro en el centro
    paint.color = Colors.black;
    canvas.drawCircle(center, radius * 0.02, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Clock12Hour extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        size: const Size(300, 300), // Tamaño del reloj
        painter: ClockPainter12Hours(currentTime: DateTime.now()),
      ),
    );
  }
}
