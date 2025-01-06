import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recibo_facil/const/colors_constants.dart';
import 'package:recibo_facil/src/home/blocs/home_cubit.dart';
import 'package:recibo_facil/src/home/blocs/utils/get_energy_advice.dart';
import 'package:recibo_facil/src/home/pages/home_page_reader.dart';

import 'package:recibo_facil/src/home/utils/custom_extension_sized.dart';
import 'package:recibo_facil/src/home/widgets/card_decoration.dart';
import 'dart:math';

import 'package:recibo_facil/src/home/widgets/title_home.dart';

import '../../services/service_locator.dart';

class HomePageAnimation extends StatefulWidget {
  @override
  _HomePageAnimationState createState() => _HomePageAnimationState();
}

class _HomePageAnimationState extends State<HomePageAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _separationAnimation;
  late Animation<double> _breathingAnimation;
  late Timer _timer;
  String _currentTime = '';
  late DateTime updatedTime;
  late final currentSegment;
  late final colors;

  late final segment;

  void _updateTime() {
    setState(() {
      _currentTime = _formatCurrentTime();
      updatedTime = DateTime.now();
    });
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

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
    currentSegment = getCurrentSegment(DateTime.now());
    colors =
        segmentColors['${currentSegment["name"]}'] ?? segmentColors["default"]!;

    _updateTime(); // Inicializa la hora al cargar
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updateTime(); // Actualiza cada segundo
    });

    segment = getSegmentForCurrentTime(
      timeToTimeOfDay(updatedTime),
      segments,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final currentTime = DateTime.now();
    final isSunday = (DateTime.now()).weekday == DateTime.sunday;

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
                        isSunday: isSunday),
                    child: SizedBox(
                      width: 300,
                      height: 300,
                    ),
                  );
                },
              ),
            ),
            40.ht,
            Padding(
              padding: EdgeInsets.only(left: size.width * 0.09),
              child: EnergyTip(
                  icon: Icons.lightbulb,
                  text: "Hora actual $_currentTime",
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
                      updatedTime: updatedTime,
                      peakWidgets: segment["widgets"] as List<Widget>,
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
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: getIt<HomeCubit>(),
                      child: HomePageReader(),
                    ),
                  ),
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
  final bool isSunday;

  CircleWithLabelsPainter({
    required this.separation,
    required this.radius,
    required this.activeSegmentName,
    required this.animationFactor,
    required this.isSunday,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);

    // Si es domingo, dibujar todo el círculo de verde
    if (isSunday) {
      paint.color = Colors.green;

      // Dibujar el círculo completo
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2, // Inicia en -90 grados
        2 * pi, // Barrido de 360 grados
        true,
        paint,
      );

      // Añadir etiqueta para "Horas Valle"
      final textPainter = TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        text: const TextSpan(
          children: [
            TextSpan(
              text: "Horas Valle\n",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextSpan(
              text: "Todo el día",
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          center.dx - textPainter.width / 2,
          center.dy - textPainter.height / 2,
        ),
      );

      return; // Finaliza el dibujo aquí si es domingo
    }

    // Colors and labels for sections
    final sections = [
      {
        "color": Colors.green,
        "startAngle": -90.0,
        "sweepAngle": 120.0, // 00:00 - 08:00 (Horas Valle)
        "label": "Horas Valle\n",
        "timeRange": "(00:00 - 08:00)",
        "labelAngle": -30.0,
      },
      {
        "color": Colors.yellow,
        "startAngle": 30.0,
        "sweepAngle": 30.0, // 08:00 - 10:00 (Horas Llano)
        "label": "Horas Llano\n",
        "timeRange": "(08:00 - 10:00)",
        "labelAngle": 45.0,
      },
      {
        "color": Colors.red,
        "startAngle": 60.0,
        "sweepAngle": 60.0, // 10:00 - 14:00 (Horas Punta)
        "label": "Horas Punta\n",
        "timeRange": "(10:00 - 14:00)",
        "labelAngle": 90.0,
      },
      {
        "color": Colors.yellow,
        "startAngle": 120.0,
        "sweepAngle": 60.0, // 14:00 - 18:00 (Horas Llano)
        "label": "Horas Llano\n",
        "timeRange": "(14:00 - 18:00)",
        "labelAngle": 135.0,
      },
      {
        "color": Colors.red,
        "startAngle": 180.0,
        "sweepAngle": 60.0, // 18:00 - 22:00 (Horas Punta)
        "label": "Horas Punta\n",
        "timeRange": "(18:00 - 22:00)",
        "labelAngle": 225.0,
      },
      {
        "color": Colors.yellow,
        "startAngle": 240.0,
        "sweepAngle": 60.0, // 22:00 - 00:00 (Horas Llano)
        "label": "Horas Llano\n",
        "timeRange": "(22:00 - 00:00)",
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
