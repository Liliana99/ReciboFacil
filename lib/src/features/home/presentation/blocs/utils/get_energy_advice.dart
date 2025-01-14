import 'package:flutter/material.dart';
import 'package:recibo_facil/const/assets_constants.dart';
import 'package:recibo_facil/src/features/home/presentation/utils/custom_extension_sized.dart';

class EnergySegmentAdvice extends StatelessWidget {
  final DateTime currentTime;
  final TextStyle parenthesisStyle;
  final Color? generalColorStyle;
  final DateTime updatedTime;
  final List<Widget> peakWidgets;

  const EnergySegmentAdvice({
    required this.currentTime,
    required this.parenthesisStyle,
    required this.updatedTime,
    required this.peakWidgets,
    this.generalColorStyle,
  });

  @override
  Widget build(BuildContext context) {
    // Definir los segmentos con consejos específicos e imágenes
    final currentSegment = getCurrentSegment(updatedTime);

    // Construir la interfaz con texto y las imágenes correspondientes
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          50.ht,
          Expanded(
            flex: 2,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                    fontSize: 22, color: generalColorStyle ?? Colors.black),
                children: [
                  TextSpan(
                    text: "Estamos en el segmento  ",
                  ),
                  TextSpan(
                    text: "\n\n",
                  ),
                  TextSpan(
                    text: "${currentSegment["name"]}. ",
                    style: parenthesisStyle,
                  ),
                  TextSpan(
                    text: "\n\n",
                  ),
                  WidgetSpan(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      currentSegment["tip"] ?? "",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )),
                  TextSpan(
                    text: "\n",
                  ),
                ],
              ),
            ),
          ),

          // Mostrar imágenes dinámicas basadas en el segmento actual
          if (currentSegment["name"] != 'Horas Punta')
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: (currentSegment["images"] as List<dynamic>)
                      .cast<
                          String>() // Realizamos el cast explícito a List<String>
                      .map((imagePath) {
                    return Image.asset(
                      imagePath,
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                    );
                  }).toList(),
                ),
              ),
            ),
          if (currentSegment["name"] == 'Horas Punta')
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: peakWidgets,
                ),
              ),
            ),
          Spacer(),
        ],
      ),
    );
  }
}

final segments = [
  {
    "name": "Horas Valle",
    "range": "00:00 AM - 08:00 AM",
    "periods": [
      {
        "start": TimeOfDay(hour: 0, minute: 0),
        "end": TimeOfDay(hour: 8, minute: 0),
      },
    ],
    "tip": "Puedes enchufar dispositivos de alto consumo.",
    "images": [
      Assets.microWave,
      Assets.washingMachine,
      Assets.oven,
      Assets.electricStove,
    ],
  },
  {
    "name": "Horas Llano",
    "range": "08:00 AM - 10:00 AM / 02:00 PM - 06:00 PM / 10:00 PM - 12:00 AM",
    "periods": [
      {
        "start": TimeOfDay(hour: 8, minute: 0),
        "end": TimeOfDay(hour: 10, minute: 0),
      },
      {
        "start": TimeOfDay(hour: 14, minute: 0),
        "end": TimeOfDay(hour: 18, minute: 0),
      },
      {
        "start": TimeOfDay(hour: 22, minute: 0),
        "end": TimeOfDay(hour: 23, minute: 59),
      },
    ],
    "tip": "Enchufa dispositivos moderadamente.",
    "images": [
      Assets.washingMachine,
      Assets.dishWasher,
      Assets.vacuumCleaner,
    ],
  },
  {
    "name": "Horas Punta",
    "range": "10:00 AM - 02:00 PM / 06:00 PM - 10:00 PM",
    "periods": [
      {
        "start": TimeOfDay(hour: 10, minute: 0),
        "end": TimeOfDay(hour: 14, minute: 0),
      },
      {
        "start": TimeOfDay(hour: 18, minute: 0),
        "end": TimeOfDay(hour: 22, minute: 0),
      },
    ],
    "tip": "Evita dispositivos de alto consumo.",
    "images": [
      Assets.heating,
      Assets.airConditioner,
    ],
  },
];

// Helper: Verificar si una hora está dentro de múltiples rangos
bool isTimeInRanges(TimeOfDay current, List<Map<String, TimeOfDay>> periods) {
  for (final period in periods) {
    final start = period["start"]!;
    final end = period["end"]!;
    if (isTimeInRange(current, start, end)) {
      return true;
    }
  }
  return false;
}

// Encontrar el segmento correspondiente
Map<String, dynamic> getCurrentSegment(final DateTime currentTime) {
  final current = timeToTimeOfDay(currentTime);

  // Obtener la lista de días festivos para el año actual
  final holidays = getHolidaysForCurrentYear(currentTime.year);

  // Si es domingo o festivo, todo es "Horas Valle"
  if (currentTime.weekday == DateTime.sunday ||
      isHoliday(currentTime, holidays)) {
    return {
      "name": "Horas Valle",
      "range": "Todo el día",
      "tip": "Puedes enchufar dispositivos de alto consumo todo el día.",
      "images": [
        Assets.microWave,
        Assets.washingMachine,
        Assets.oven,
        Assets.electricStove,
      ]
    };
  }

  // Evaluar segmentos para días normales
  for (final segment in segments) {
    final periods = segment["periods"] as List<Map<String, TimeOfDay>>;
    if (isTimeInRanges(current, periods)) {
      return segment;
    }
  }

  // Si no se encuentra un segmento
  return {
    "name": "Sin segmento",
    "range": "N/A",
    "tip": "No hay información disponible para este horario.",
    "images": []
  };
}

// Obtener la lista de días festivos dinámicamente según el año en curso
List<DateTime> getHolidaysForCurrentYear(int year) {
  return [
    DateTime(year, 1, 1), // Año Nuevo
    DateTime(year, 12, 25), // Navidad
    DateTime(year, 5, 1), // Día del Trabajador
    DateTime(year, 8, 15), // Asunción de la Virgen
  ];
}

// Verificar si la fecha es un día festivo
bool isHoliday(DateTime currentDate, List<DateTime> holidays) {
  return holidays.any((holiday) =>
      holiday.month == currentDate.month && holiday.day == currentDate.day);
}

// Helper: Convertir DateTime a TimeOfDay
TimeOfDay timeToTimeOfDay(DateTime time) {
  return TimeOfDay(hour: time.hour, minute: time.minute);
}

// Helper: Comparar si una hora está dentro de un rango
bool isTimeInRange(TimeOfDay current, TimeOfDay start, TimeOfDay end) {
  final currentMinutes = current.hour * 60 + current.minute;
  final startMinutes = start.hour * 60 + start.minute;
  final endMinutes = end.hour * 60 + end.minute;

  if (startMinutes <= endMinutes) {
    // Rango normal, sin cruzar la medianoche
    return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
  } else {
    // Rango que cruza la medianoche
    return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
  }
}
