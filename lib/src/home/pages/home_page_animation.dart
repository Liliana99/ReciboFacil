import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recibo_facil/const/colors_constants.dart';
import 'package:recibo_facil/src/home/blocs/utils/get_energy_advice.dart';
import 'package:recibo_facil/src/home/pages/home_page_reader.dart';
import 'package:recibo_facil/src/home/utils/current_time_format_12.dart';
import 'package:recibo_facil/src/home/utils/custom_extension_sized.dart';
import 'package:recibo_facil/src/home/widgets/card_decoration.dart';
import 'dart:math';

import 'package:recibo_facil/src/home/widgets/title_home.dart';

class HomePageAnimation extends StatefulWidget {
  @override
  _HomePageAnimationState createState() => _HomePageAnimationState();
}

class _HomePageAnimationState extends State<HomePageAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _separationAnimation;
  late Animation<double> _breathingAnimation;

  final currentTime = DateTime.now();
  late final currentSegment;
  late final colors;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _separationAnimation = Tween<double>(begin: 0, end: 30).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _breathingAnimation = Tween<double>(begin: 100, end: 120).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    currentSegment = getCurrentSegment(currentTime);
    colors =
        segmentColors['${currentSegment["name"]}'] ?? segmentColors["default"]!;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Spacer(),
            HomeTitle(),
            60.ht,
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: CircleWithLabelsPainter(
                      separation: _separationAnimation.value,
                      radius: _breathingAnimation.value,
                      activeSegmentName: '${currentSegment["name"]}',
                      animationFactor: _controller.value * 0.2,
                    ),
                    child: SizedBox(
                      width: 300,
                      height: 300,
                    ),
                  );
                },
              ),
            ),
            10.ht,
            Padding(
              padding: EdgeInsets.only(left: size.width * 0.09),
              child: EnergyTip(
                  icon: Icons.lightbulb,
                  text: "Hora actual ${getCurrentTime12HourFormat()}",
                  newStyte: GoogleFonts.raleway(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  color: Colors.yellow),
            ),
            5.ht,
            SizedBox(
              width: size.width * 0.80,
              height: size.height * 0.20,
              child: CardContainer(
                  childText: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 14),
                    child: EnergySegmentAdvice(
                      currentTime: currentTime,
                      parenthesisStyle: TextStyle(
                          color: colors["border"]!,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  segmentTime: '${currentSegment["name"]}'),
            ),
            50.ht,
            SizedBox(
              width: size.width * 0.85,
              child: FilledButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePageReader()),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor:
                      ColorsApp.baseColorApp, // Color independiente del tema
                ),
                child: Text('Leer factura'),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}

class CircleWithLabelsPainter extends CustomPainter {
  final double separation;
  final double radius;
  final String activeSegmentName; // Segmento activo por nombre
  final double animationFactor; // Factor de animación para el segmento activo

  CircleWithLabelsPainter({
    required this.separation,
    required this.radius,
    required this.activeSegmentName,
    required this.animationFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);

    // Colors and labels for sections
    final sections = [
      {
        "color": Colors.green,
        "startAngle": -90.0,
        "sweepAngle": 120.0,
        "label": "Horas Valle\n",
        "timeRange": "(12:00-4:00)",
        "labelAngle": -30.0,
      },
      {
        "color": Colors.yellow,
        "startAngle": 30.0,
        "sweepAngle": 60.0,
        "label": "Horas Llano\n",
        "timeRange": "(4:00-6:00)",
        "labelAngle": 45.0,
      },
      {
        "color": Colors.red,
        "startAngle": 90.0,
        "sweepAngle": 90.0,
        "label": "Horas Punta\n",
        "timeRange": "(6:00-9:00)",
        "labelAngle": 135.0,
      },
      {
        "color": Colors.yellow,
        "startAngle": 180.0,
        "sweepAngle": 60.0,
        "label": "Horas Llano\n",
        "timeRange": "(9:00-11:00)",
        "labelAngle": 225.0,
      },
      {
        "color": Colors.red,
        "startAngle": 240.0,
        "sweepAngle": 30.0,
        "label": "Horas Punta\n",
        "timeRange": "(11:00-12:00)",
        "labelAngle": 270.0,
      },
    ];

    // Draw segments with animation
    for (int i = 0; i < sections.length; i++) {
      final section = sections[i];
      paint.color = section["color"] as Color;

      final angle = (section["startAngle"] as double) * pi / 180;
      final dx = cos(angle) * separation;
      final dy = sin(angle) * separation;

      canvas.save();

      // Animar solo el segmento activo
      final isActive = (section["label"] as String).trim() == activeSegmentName;
      if (isActive) {
        // Mover un poco más hacia el lado opuesto para evitar la superposición
        final additionalOffset = 10.0 * animationFactor;
        canvas.translate(center.dx + dx - additionalOffset, center.dy + dy);
        canvas.scale(1 + animationFactor, 1 + animationFactor);
      } else {
        canvas.translate(center.dx, center.dy);
      }

      canvas.drawArc(
        Rect.fromCircle(center: Offset(0, 0), radius: radius),
        angle,
        (section["sweepAngle"] as double) * pi / 180,
        true,
        paint,
      );
      canvas.restore();

      // Draw labels
      final labelAngle = (section["labelAngle"] as double) * pi / 180;
      final textOffset = Offset(
        center.dx + (radius + 20) * cos(labelAngle),
        center.dy + (radius + 20) * sin(labelAngle),
      );

      final textPainter = TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        text: TextSpan(
          children: [
            TextSpan(
              text: section["label"] as String,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            TextSpan(
              text: section["timeRange"] as String,
              style: const TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: Colors.red,
                  fontWeight: FontWeight.w600),
            ),
          ],
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
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class EnergyTip extends StatelessWidget {
  final IconData? icon;
  final String text;
  final Color color;
  final TextStyle? newStyte;

  EnergyTip(
      {required this.icon,
      required this.text,
      required this.color,
      this.newStyte});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) Icon(icon, color: color, size: 24),
        if (icon != null) SizedBox(width: 8),
        Flexible(
            child: Text(
          text,
          style: newStyte ?? TextStyle(fontSize: 16),
          textAlign: TextAlign.left,
        )),
      ],
    );
  }
}
