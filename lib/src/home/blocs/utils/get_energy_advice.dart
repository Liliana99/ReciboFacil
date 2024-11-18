import 'package:flutter/material.dart';
import 'package:recibo_facil/const/assets_constants.dart';

class EnergySegmentAdvice extends StatelessWidget {
  final DateTime currentTime;
  final TextStyle parenthesisStyle;

  const EnergySegmentAdvice({
    required this.currentTime,
    required this.parenthesisStyle,
  });

  @override
  Widget build(BuildContext context) {
    // Definir los segmentos con consejos específicos e imágenes

    final currentSegment = getCurrentSegment(currentTime);

    // Construir la interfaz con texto y las imágenes correspondientes
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(fontSize: 16, color: Colors.black),
              children: [
                TextSpan(
                  text: "Estamos en el segmento: ",
                ),
                TextSpan(
                  text: "${currentSegment["name"]} ",
                  style: parenthesisStyle,
                ),
                TextSpan(
                  text:
                      "(${currentSegment["range"]}) : ${currentSegment["tip"]}",
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          // Mostrar imágenes dinámicas basadas en el segmento actual
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: (currentSegment["images"] as List<dynamic>)
                .cast<String>() // Realizamos el cast explícito a List<String>
                .map((imagePath) {
              return Image.asset(
                imagePath,
                width: 35,
                height: 35,
                fit: BoxFit.contain,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// Helper para aplicar estilo personalizado al texto entre paréntesis
String styleText(String text, TextStyle style) {
  return '\u001b[38;5;${style.color!.value}m$text\u001b[0m';
}

final segments = [
  {
    "name": "Horas Valle",
    "range": "12:00 AM - 04:00 AM",
    "start": TimeOfDay(hour: 0, minute: 0),
    "end": TimeOfDay(hour: 4, minute: 0),
    "tip": "Puedes enchufar dispositivos de alto consumo.",
    "images": [
      Assets.microWave,
      Assets.washingMachine,
      Assets.oven,
      Assets.electricStove,
    ]
  },
  {
    "name": "Horas Llano",
    "range": "04:00 AM - 06:00 AM",
    "start": TimeOfDay(hour: 4, minute: 0),
    "end": TimeOfDay(hour: 6, minute: 0),
    "tip": "Enchufa dispositivos moderadamente.",
    "images": [Assets.washingMachine, Assets.dishWasher]
  },
  {
    "name": "Horas Punta",
    "range": "06:00 AM - 09:00 AM",
    "start": TimeOfDay(hour: 6, minute: 0),
    "end": TimeOfDay(hour: 9, minute: 0),
    "tip": "Evita dispositivos de alto consumo.",
    "images": []
  },
  {
    "name": "Horas Llano",
    "range": "09:00 AM - 04:00 PM",
    "start": TimeOfDay(hour: 9, minute: 0),
    "end": TimeOfDay(hour: 16, minute: 0),
    "tip": "Prioriza dispositivos necesarios.",
    "images": [Assets.dishWasher, Assets.microWave]
  },
  {
    "name": "Horas Valle",
    "range": "06:00 PM - 12:00 AM",
    "start": TimeOfDay(hour: 18, minute: 0),
    "end": TimeOfDay(hour: 23, minute: 59),
    "tip": "Usa cómodamente dispositivos de alto consumo.",
    "images": [
      Assets.microWave,
      Assets.dishWasher,
      Assets.oven,
      Assets.heating,
      Assets.electricStove,
    ]
  }
];

// Helper: Convertir DateTime a TimeOfDay
TimeOfDay timeToTimeOfDay(DateTime time) {
  return TimeOfDay(hour: time.hour, minute: time.minute);
}

// Helper: Comparar si una hora está dentro de un rango
bool isTimeInRange(TimeOfDay current, TimeOfDay start, TimeOfDay end) {
  final currentMinutes = current.hour * 60 + current.minute;
  final startMinutes = start.hour * 60 + start.minute;
  final endMinutes = end.hour * 60 + end.minute;

  return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
}

// Encontrar el segmento correspondiente
Map<String, dynamic> getCurrentSegment(final DateTime currentTime) {
  final current = timeToTimeOfDay(currentTime);

  for (final segment in segments) {
    final start = segment["start"] as TimeOfDay;
    final end = segment["end"] as TimeOfDay;

    // Depurar comparaciones
    print("Hora actual: ${current.hour}:${current.minute}");
    print(
        "Comparando con segmento: ${segment["name"]} (${start.hour}:${start.minute} - ${end.hour}:${end.minute})");

    if (isTimeInRange(current, start, end)) {
      print("Segmento encontrado: ${segment["name"]}");
      return segment;
    }
  }

  // Si no se encuentra un segmento
  print("No se encontró segmento para la hora actual.");
  return {
    "name": "Sin segmento",
    "range": "N/A",
    "tip": "No hay información disponible para este horario.",
    "images": []
  };
}
