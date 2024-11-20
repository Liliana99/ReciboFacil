import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

Future<String?> processRecognizedText(RecognizedText recognizedText) async {
  print("Iniciando análisis del texto OCR...");

  // Expresión regular para detectar valores en formato "XX,XX €"
  final valueWithCurrencyRegex = RegExp(r"([0-9]+,[0-9]{2})\s*€");

  // Variable para almacenar el último valor monetario detectado
  String? lastValueWithCurrency;

  // Variable para confirmar si se encontró "Total importe a pagar"
  bool foundTotalLabel = false;

  // Recorrer todos los bloques
  for (int blockIndex = 0;
      blockIndex < recognizedText.blocks.length;
      blockIndex++) {
    final block = recognizedText.blocks[blockIndex];
    final blockText = block.text.trim();

    // Imprimir el bloque para diagnóstico
    print("Analizando bloque ${blockIndex + 1}: ${blockText}");

    // Si se encuentra "Total importe a pagar", marcarlo como encontrado
    if (blockText.contains("Total importe a pagar")) {
      print(
          "Etiqueta encontrada: 'Total importe a pagar' en bloque ${blockIndex + 1}");
      foundTotalLabel = true;
    }

    // Buscar valores numéricos con "€" en el bloque
    final matches = valueWithCurrencyRegex.allMatches(blockText);
    for (final match in matches) {
      lastValueWithCurrency =
          match.group(1); // Actualizar el último valor encontrado
      print(
          "Valor numérico con moneda detectado: ${match.group(1)} € en bloque ${blockIndex + 1}");
    }
  }

  // Verificar si se encontró "Total importe a pagar"
  if (!foundTotalLabel) {
    print("No se encontró la etiqueta 'Total importe a pagar'");
    return null;
  }

  // Devolver el último valor monetario detectado
  if (lastValueWithCurrency != null) {
    print("Último valor monetario detectado: $lastValueWithCurrency €");
    return lastValueWithCurrency;
  }

  print("No se encontró ningún valor monetario relevante");
  return null;
}

Future<String?> processBillingMonth(RecognizedText recognizedText) async {
  String fullText = '';
  for (TextBlock block in recognizedText.blocks) {
    for (TextLine line in block.lines) {
      fullText += line.text + '\n';
    }
  }
  print("Texto reconocido completo:\n$fullText");

  List<String> lines = fullText.split('\n');

  for (String line in lines) {
    if (line.contains("Suscripción de")) {
      final subscriptionRegex = RegExp(
          r"Suscripción de\s*(\d{2}/?\d{2}/?\d{4})\s*a\s*(\d{2}/\d{2}/\d{4})");
      final match = subscriptionRegex.firstMatch(line);

      if (match != null) {
        String startDate = match.group(1) ?? "";
        String endDate = match.group(2) ?? "";

        if (startDate.length == 9 && startDate.contains('/')) {
          // Caso específico "01/042024", donde falta la barra entre mes y año
          startDate = '${startDate.substring(0, 5)}/${startDate.substring(5)}';
        }

        // Asegurarse de que startDate esté en formato dd/MM/yyyy
        if (startDate.length == 8 &&
            startDate.contains(RegExp(r'^\d{2}/\d{4}$'))) {
          // Caso sin delimitadores entre mes y año, ej. "01/042024"
          startDate =
              '${startDate.substring(0, 2)}/${startDate.substring(2, 4)}/${startDate.substring(4)}';
        } else if (startDate.length == 8) {
          // Caso sin delimitadores, ej. "01/042024"
          startDate =
              '${startDate.substring(0, 2)}/${startDate.substring(2, 4)}/${startDate.substring(4)}';
        }

        print("Fecha de inicio normalizada: $startDate");

        try {
          DateTime startDateTime =
              DateTime.parse(startDate.split('/').reversed.join('-'));
          String billingMonth =
              "${_getMonthName(startDateTime.month)} ${startDateTime.year}";

          print("Mes facturado: $billingMonth");
          return billingMonth;
        } catch (e) {
          print("Error al parsear la fecha de inicio: $e");
        }
      } else {
        print("Formato de fecha no encontrado en la línea.");
      }
    }
  }

  print("Período de suscripción no encontrado en el texto.");
  return null; // Retorna null si no se encuentra el valor
}

// Función para obtener el nombre del mes en español
String _getMonthName(int month) {
  const months = [
    "enero",
    "febrero",
    "marzo",
    "abril",
    "mayo",
    "junio",
    "julio",
    "agosto",
    "septiembre",
    "octubre",
    "noviembre",
    "diciembre"
  ];
  return months[month - 1];
}

String? getValueWithCurrency(String text) {
  final valueWithCurrencyRegex = RegExp(r"([0-9]+,[0-9]{2})\s*€");
  final match = valueWithCurrencyRegex.firstMatch(text);

  if (match != null) {
    final value = match.group(1); // Capturar el valor
    return value;
  } else {
    print("No se encontró un valor numérico con moneda en esta línea.");
  }
  return null;
}

String? extractBillingPeriod(String line) {
  // Expresión regular para capturar el contenido después de "Periodo de facturación:"
  final periodRegex = RegExp(r"Periodo de facturación:\s*(.*)");
  final match = periodRegex.firstMatch(line);

  if (match != null) {
    var period = match.group(1)?.trim(); // Capturar y limpiar el contenido
    if (period != null && period.isNotEmpty) {
      // Remover "del " del inicio si está presente
      if (period.startsWith("del ")) {
        period = period.replaceFirst("del ", "");
      }
      print("Billing period found: $period");
      return period; // Devolver directamente el periodo procesado
    }
  }
  print("No billing period information found in this line.");
  return null;
}
