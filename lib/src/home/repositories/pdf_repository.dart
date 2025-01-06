import 'package:decimal/decimal.dart';
import 'package:diacritic/diacritic.dart';
import 'package:pdfrx/pdfrx.dart';

class PdfRepository {
  Future<ResponsePdfReader> searchTextOnPdf(
      PdfDocument document, List<String> queries) async {
    List<String> queriesNormalized = [];

    if (document.pages.isEmpty) {
      print("El documento no contiene páginas.");
      return ResponsePdfReader(scannedText: 'No se encontró el término');
    }

    var response = ResponsePdfReader(scannedText: '');

    try {
      bool isInEnergyConsumptionSection = false;
      // Iterar por todas las páginas del documento
      for (int page = 1; page <= document.pages.length; page++) {
        final pageText = await document.pages[page - 1].loadText();

        if (pageText != null) {
          if (queriesNormalized.isEmpty) {
            // Limpiar y normalizar el término de búsqueda (query)
            for (String query in queries) {
              if (query != "nº factura") {
                query = removeDiacritics(query).toLowerCase();
                queriesNormalized.add(query);
              } else {
                queriesNormalized.add(query);
              }
              if (query == "nº factura") {
                final match = RegExp(r"nº factura:\s*([^\s]+)")
                    .firstMatch(pageText.fullText.toLowerCase());
                if (match != null) {
                  final facturaValue =
                      match.group(1); // El valor después de "nº factura:"
                  print("Valor encontrado para 'nº factura': $facturaValue");
                  if (response.billNumber == null) {
                    response = response.copyWith(billNumber: facturaValue);
                  }
                }
              }
            }
          }

          response =
              response.copyWith(company: extractCompanyInfo(pageText.fullText));

          final lines = pageText.fullText.split('\n');

          // Variable para acumular coincidencias de "contrato"
          List<String> contratoMatches = [];
          final queriesRemaining = queriesNormalized.toSet();

          for (var line in lines) {
            String cleanedLine = removeDiacritics(line).toLowerCase();

            if (cleanedLine.isNotEmpty) {
              print("Línea actual (limpia): $cleanedLine");

              for (var query in queriesRemaining.toList()) {
                // Acumular datos relacionados con "contrato"
                if (query == "contrato" && cleanedLine.contains(query)) {
                  // Verificar si la línea ya existe en la lista antes de agregarla
                  if (!contratoMatches.contains(line.trim())) {
                    contratoMatches.add(line.trim());
                    print("Línea agregada a contratoMatches: ${line.trim()}");
                  } else {
                    print("Línea duplicada no agregada: ${line.trim()}");
                  }
                }

                if (query == "cups" && cleanedLine.contains(query)) {
                  if (response.cups == null) {
                    response = response.copyWith(cups: extractCups(line));
                    queriesRemaining.remove(query);
                    break;
                  }
                }

                // Detectar la sección de "INFORMACIÓN DEL CONSUMO ELÉCTRICO"
                if (cleanedLine.contains("informacion del consumo electrico")) {
                  isInEnergyConsumptionSection = true;
                  print("Entrando en la sección de consumo eléctrico.");
                  continue; // Continuamos para la próxima línea, ya que sabemos que estamos dentro de esta sección
                }

                // Salir de la sección si encontramos otra sección diferente
                if (isInEnergyConsumptionSection &&
                    (cleanedLine.contains("detalle de factura") ||
                        cleanedLine.contains("total a pagar"))) {
                  isInEnergyConsumptionSection = false;
                  queriesRemaining.remove(query);
                  print("Saliendo de la sección de consumo eléctrico.");
                  break;
                }

                if (cleanedLine.contains(query)) {
                  print("Término encontrado en la página $page: $line");

                  if (query == "periodo de facturacion" &&
                      response.month == null) {
                    response =
                        response.copyWith(month: extractBillingPeriod(line));

                    print('Contenido de response.month: ${response.month}');
                  } else if (query == "a pagar" &&
                      response.totalAmount == null) {
                    response = response.copyWith(
                        totalAmount: getValueWithCurrency(line));

                    print(
                        'Contenido de response.totalAmount: ${response.totalAmount}');
                  }

                  response = response.copyWith(
                    scannedText: response.scannedText.isEmpty
                        ? line
                        : '${response.scannedText}\n$line',
                  );
                  queriesRemaining.remove(query);
                  break;
                }

                // Buscar los valores de los segmentos de energía
                if (cleanedLine
                        .contains(removeDiacritics("Valle").toLowerCase()) &&
                    response.consumptionValle == null) {
                  print("Encontrado segmento Valle: $line");
                  response = response.copyWith(
                      consumptionValle:
                          extractConsumptionValueFromSegment(line, "valle"));
                  print(
                      'Valor de consumo para Valle: ${response.consumptionValle}');
                }
                if (cleanedLine.contains("punta") &&
                    response.consumptionPunta == null) {
                  print("Encontrado segmento Punta: $line");
                  response = response.copyWith(
                      consumptionPunta:
                          extractConsumptionValueFromSegment(line, "punta"));
                  print(
                      'Valor de consumo para Punta: ${response.consumptionPunta}');
                }
                if (cleanedLine.contains("llano") &&
                    response.consumptionLlano == null) {
                  print("Encontrado segmento Llano: $line");
                  response = response.copyWith(
                      consumptionLlano:
                          extractConsumptionValueFromSegment(line, "llano"));
                  print(
                      'Valor de consumo para Llano: ${response.consumptionLlano}');
                }
                if (contratoMatches.isNotEmpty) {
                  final contratoData = contratoMatches.join(', ');
                  print("Datos acumulados para 'contrato': $contratoData");
                  response = response.copyWith(
                    contract: contratoData,
                  );
                }
              }
            }
          }
        } else {
          print("No se pudo cargar el texto de la página $page.");
        }

        // Detener el bucle si todos los valores se encuentran
        if (response.consumptionValle != Decimal.zero &&
            response.consumptionLlano != Decimal.zero &&
            response.consumptionPunta != Decimal.zero) {
          break;
        }
      }

      print("Búsqueda finalizada.");

      if (response.month != null ||
          response.totalAmount != null ||
          response.consumptionPunta != Decimal.zero ||
          response.consumptionLlano != Decimal.zero ||
          response.consumptionValle != Decimal.zero) {
        return response;
      } else {
        return ResponsePdfReader(
          scannedText: '',
          month: null,
          totalAmount: null,
          consumptionPunta: Decimal.zero,
          consumptionLlano: Decimal.zero,
          consumptionValle: Decimal.zero,
        );
      }
    } on Exception catch (e) {
      print("Error durante la búsqueda: $e");
    }

    return ResponsePdfReader(
      scannedText: '',
      month: null,
      totalAmount: null,
      consumptionPunta: Decimal.zero,
      consumptionLlano: Decimal.zero,
      consumptionValle: Decimal.zero,
    );
  }
}

String? extractCups(String line) {
  // Convertir la línea a mayúsculas para normalizar
  final normalizedLine = line.toUpperCase();
  // Expresión regular para buscar el CUPS
  final cupsRegex = RegExp(r'[A-Z]{2}[A-Z0-9]{20,}');

  // Buscar coincidencias
  final match = cupsRegex.firstMatch(normalizedLine);

  // Retornar el CUPS encontrado o null si no hay coincidencias
  return match?.group(0);
}

Decimal extractConsumptionValue(String line, {String? keyword}) {
  // Expresión regular mejorada para detectar valores grandes con comas, puntos y espacios
  final consumptionPattern = RegExp(r'(\d{1,3}(?:[.,]\d{3})*|\d+)([.,]\d+)?');
  final matches = consumptionPattern.allMatches(line);

  for (var match in matches) {
    String value = match.group(0)!;

    // Limpiar el valor: remover puntos que actúan como separadores de miles y cambiar comas decimales a puntos
    value = value.replaceAll('.', '').replaceAll(',', '.');

    // Si se proporcionó un keyword, validar que esté cerca del valor encontrado
    if (keyword != null &&
        !line.toLowerCase().contains(keyword.toLowerCase())) {
      continue; // Si el keyword no está en la línea, seguir buscando
    }

    print("Valor de consumo encontrado y limpiado: $value");

    try {
      return Decimal.parse(value);
    } catch (e) {
      print("Error al parsear el valor de consumo: $value");
    }
  }

  print("No se encontró un valor adecuado de consumo en la línea: $line");
  return Decimal.zero;
}

String? extractBillingPeriod(String line) {
  // Expresión regular para buscar un rango de fechas, ej: "del 22/09/2024 a 21/10/2024"
  final billingPeriodPattern =
      RegExp(r'del (\d{2}/\d{2}/\d{4}) a (\d{2}/\d{2}/\d{4})');
  final match = billingPeriodPattern.firstMatch(line);

  print("Intentando extraer periodo de facturación de la línea: $line");

  if (match != null) {
    final startDate = match.group(1);
    final endDate = match.group(2);
    print(
        "Entro antes de devolver este valor. Intentando extraer periodo de facturación de la línea: $line");
    return 'Desde $startDate hasta $endDate';
  }

  return null; // Si no encuentra el patrón, retorna null
}

String? getValueWithCurrency(String line) {
  // Implementar lógica para extraer valores con moneda
  final currencyPattern = RegExp(r'(\d{1,3}([.,]\d{3})*|\d+)([.,]\d+)?\s*[€$]');
  final match = currencyPattern.firstMatch(line);
  if (match != null) {
    String value = match.group(0)!;

    // Remover símbolos de moneda y limpiar el valor
    value = value.replaceAll(RegExp(r'[€$]'), '').trim();
    value = value.replaceAll('.', '').replaceAll(',', '.');

    return value;
  }
  return null;
}

String _cleanLine(String line) {
  // Limpiar caracteres invisibles o espacios innecesarios
  return line.trim().toLowerCase().replaceAll(RegExp(r'[^\x20-\x7E]'), '');
}

String? extractCompanyInfo(String pdfText) {
  // Expresión regular para encontrar CIF
  final cifRegex = RegExp(r'\bCIF\s[A-Z]\d{8}\b', caseSensitive: false);

  // Expresión regular para encontrar nombres de empresas
  final nameRegex = RegExp(
      r'[A-Za-z\s.,ñÑáéíóúÁÉÍÓÚ\-]+s\.a\.?(\s+unipersonal)?',
      caseSensitive: false);

  // Encontrar el CIF en el texto
  final cifMatch = cifRegex.firstMatch(pdfText);

  // Encontrar el nombre de la empresa en el texto
  final nameMatch = nameRegex.firstMatch(pdfText);

  // Imprimir resultados
  if (cifMatch != null && nameMatch != null) {
    final cif = cifMatch.group(0) ?? '';
    final name = nameMatch.group(0) ?? '';

    print('Empresa encontrada: $name');
    print('CIF: $cif');
    return name;
  } else {
    print('No se pudo encontrar información de la empresa.');
  }
}

class ResponsePdfReader {
  final String scannedText;
  final String? month;
  final String? totalAmount;
  final Decimal? consumptionPunta;
  final Decimal? consumptionLlano;
  final Decimal? consumptionValle;
  final String? company;
  final String? billNumber;
  final String? cups;
  final String? contract;

  ResponsePdfReader({
    required this.scannedText,
    this.month,
    this.totalAmount,
    this.consumptionPunta,
    this.consumptionLlano,
    this.consumptionValle,
    this.company,
    this.billNumber,
    this.cups,
    this.contract,
  });

  ResponsePdfReader copyWith({
    String? scannedText,
    String? month,
    String? totalAmount,
    Decimal? consumptionPunta,
    Decimal? consumptionLlano,
    Decimal? consumptionValle,
    String? company,
    String? billNumber,
    String? cups,
    String? contract,
  }) {
    return ResponsePdfReader(
      scannedText: scannedText ?? this.scannedText,
      month: month ?? this.month,
      totalAmount: totalAmount ?? this.totalAmount,
      consumptionPunta: consumptionPunta ?? this.consumptionPunta,
      consumptionLlano: consumptionLlano ?? this.consumptionLlano,
      consumptionValle: consumptionValle ?? this.consumptionValle,
      company: company ?? this.company,
      billNumber: billNumber ?? this.billNumber,
      cups: cups ?? this.cups,
      contract: contract ?? this.contract,
    );
  }
}

Decimal extractConsumptionValueFromSegment(String line, String keyword) {
  // Buscar el valor de consumo después de la palabra clave (ejemplo: "valle")
  final consumptionPattern =
      RegExp(r'(\d{1,3}(?:[.,]\d{3})*|\d+)([.,]\d+)?\s*kwh');

  final match = consumptionPattern.firstMatch(line);

  print('linea en el metodo $line');

  if (match != null) {
    String value = match.group(0)!;

    // Limpiar el valor: remover puntos que actúan como separadores de miles y cambiar comas decimales a puntos
    value = value
        .replaceAll(RegExp(r'[^\d,.]'), '')
        .replaceAll('.', '')
        .replaceAll(',', '.');

    print("Valor de consumo encontrado y limpiado: $value");

    try {
      return Decimal.parse(value);
    } catch (e) {
      print("Error al parsear el valor de consumo: $value");
    }
  }

  print("No se encontró un valor adecuado de consumo en la línea: $line");
  return Decimal.zero;
}
