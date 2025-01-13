import 'package:decimal/decimal.dart';
import 'package:diacritic/diacritic.dart';
import 'package:pdfrx/pdfrx.dart';

class PdfRepository {
  Future<ResponsePdfReader> searchTextOnPdf(
      PdfDocument document, List<String> queries) async {
    if (document.pages.isEmpty) {
      print("El documento no contiene páginas.");
      return ResponsePdfReader(scannedText: 'No se encontró el término');
    }

    // Variables iniciales
    List<String> queriesNormalized =
        queries.map((q) => removeDiacritics(q).toLowerCase()).toList();
    var response = ResponsePdfReader(scannedText: '');

    try {
      // Iterar por todas las páginas del documento
      for (int page = 1; page <= document.pages.length; page++) {
        final pageText = await document.pages[page - 1].loadText();

        if (pageText != null) {
          final lines = pageText.fullText.split('\n');

          final companyName = extractCompanyInfo(pageText.fullText);

          if (companyName != null) {
            print("Empresa detectada: $companyName");
            response = response.copyWith(company: companyName);
          }

          for (var line in lines) {
            String cleanedLine = removeDiacritics(line).toLowerCase();

            if (cleanedLine.isNotEmpty) {
              // Iterar sobre las consultas restantes
              for (var query in queriesNormalized.toList()) {
                if (cleanedLine.contains(query)) {
                  print("Término encontrado en la página $page: $line");

                  // Buscar "nº factura"
                  if (query == "nº factura") {
                    final match = RegExp(r"nº factura:\s*([^\s]+)")
                        .firstMatch(cleanedLine);
                    if (match != null) {
                      response =
                          response.copyWith(billNumber: match.group(1)?.trim());
                    }
                  }

                  // Buscar "periodo de facturación"
                  if (query == "periodo de facturacion") {
                    response =
                        response.copyWith(month: extractBillingPeriod(line));
                    print('Contenido de response.month: ${response.month}');
                  }

                  // Buscar "total importe a pagar"
                  if (query == "total importe a pagar") {
                    final totalInfo = extractTotalAmount('', lines);
                    if (totalInfo['totalAmount'] != null) {
                      response = response.copyWith(
                          totalAmount: totalInfo['totalAmount']);
                      print(
                          "El importe total encontrado es: ${totalInfo['totalAmount']}");
                    }
                  }

                  if (query == "cups") {
                    final cup = extractCups(line);
                    if (cup != null) {
                      response = response.copyWith(cups: cup);
                      queriesNormalized.remove(query);
                      break; // Continuar con el siguiente término
                    }
                  }

                  // Buscar "datos del contrato de electricidad"
                  if (query == "datos del contrato de electricidad") {
                    final contractDetails = extractContractDetails('', lines);
                    if (contractDetails.values
                        .every((value) => value != null)) {
                      response = response.copyWith(
                        contract: contractDetails['contractType'],
                        valleyString: contractDetails['valle'],
                        peakString: contractDetails['punta'],
                      );
                    }
                  }

                  // Buscar "información para el consumidor"
                  if (query == "informacion para el consumidor") {
                    final consumerInfo = extractConsumerInfo(lines);
                    if (consumerInfo['qrCodeLink'] != null) {
                      response = response.copyWith(
                          qrCodeLink: consumerInfo['qrCodeLink']);
                      print("Enlace encontrado: ${consumerInfo['qrCodeLink']}");
                    }
                  }

                  // Actualizar el texto escaneado y eliminar el término encontrado
                  response = response.copyWith(
                    scannedText: response.scannedText.isEmpty
                        ? line
                        : '${response.scannedText}\n$line',
                  );
                  queriesNormalized.remove(query);
                  break; // Continuar con el siguiente término
                }
              }

              // Detener el bucle si se han encontrado todas las coincidencias
              if (queriesNormalized.isEmpty) {
                print("Todas las coincidencias encontradas.");
                break;
              }
            }
          }
        } else {
          print("No se pudo cargar el texto de la página $page.");
        }
      }

      print("Búsqueda finalizada.");

      return response;
    } on Exception catch (e) {
      print("Error durante la búsqueda: $e");
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

// String? extractCompanyInfo(String pdfText) {
//   // Expresión regular para encontrar CIF
//   final cifRegex = RegExp(r'\bCIF\s[A-Z]\d{8}\b', caseSensitive: false);

//   // Dividir el texto en líneas para análisis más preciso
//   final lines = pdfText.split('\n');

//   for (int i = 0; i < lines.length; i++) {
//     final line = lines[i];

//     // Buscar la línea que contiene el CIF
//     if (cifRegex.hasMatch(line)) {
//       final cifMatch = cifRegex.firstMatch(line);

//       // Si se encuentra el CIF, buscar la línea anterior
//       if (cifMatch != null && i > 0) {
//         final previousLine = lines[i - 1].trim();

//         // Verificar que la línea anterior contenga un posible nombre de empresa
//         final nameRegex = RegExp(
//             r'[A-Za-z\s.,ñÑáéíóúÁÉÍÓÚ\-]+s\.a\.?(\s+unipersonal)?',
//             caseSensitive: false);

//         final nameMatch = nameRegex.firstMatch(previousLine);

//         if (nameMatch != null) {
//           final companyName = nameMatch.group(0)?.trim();
//           print('Empresa encontrada: $companyName');
//           print('CIF: ${cifMatch.group(0)}');
//           return companyName;
//         }
//       }
//     }
//   }

//   print('No se pudo encontrar información de la empresa.');
//   return null;
// }

Map<String, String?> extractConsumerInfo(List<String> lines) {
  bool isInConsumerSection = false;
  String? qrCodeLink;

  // Normalizar el texto clave
  final consumerInfoStart = normalizeText("INFORMACIÓN PARA EL CONSUMIDOR");
  final qrCodeRegex = RegExp(r'https://[^\s]+',
      caseSensitive: false); // Expresión para capturar enlaces

  // Iterar sobre las líneas
  for (final line in lines) {
    final normalizedLine = normalizeText(line);

    // Detectar el inicio de la sección
    if (normalizedLine.contains(consumerInfoStart)) {
      isInConsumerSection = true;
      print("Inicio de la sección 'INFORMACIÓN PARA EL CONSUMIDOR' detectado.");
      continue;
    }

    // Salir si encontramos otro segmento (en este caso "...")
    if (isInConsumerSection && normalizedLine.contains("...")) {
      print("Fin de la sección detectado.");
      break;
    }

    // Buscar el enlace si estamos en la sección
    if (isInConsumerSection) {
      final match = qrCodeRegex.firstMatch(normalizedLine);

      if (match != null) {
        qrCodeLink = match.group(0)?.trim(); // Captura el enlace
        print("Enlace encontrado: $qrCodeLink");
        break; // Detener la búsqueda después de encontrar el primer enlace
      }
    }
  }

  // Devolver el resultado en un mapa
  return {
    "qrCodeLink": qrCodeLink,
  };
}

Map<String, String?> extractTotalAmount(String line, List<String> lines) {
  String? totalAmount; // Variable para almacenar el importe total

  // Normalización del texto clave
  final totalAmountKey = normalizeText("Total importe a pagar");

  // Expresión regular para extraer el importe con formato numérico y el símbolo €
  final totalAmountRegex = RegExp(r'(\d+[,.]?\d*)\s?€');

  // Iterar sobre las líneas
  for (final line in lines) {
    final normalizedLine = normalizeText(line);

    // Verificar si la línea contiene "Total importe a pagar"
    if (normalizedLine.contains(totalAmountKey)) {
      final match = totalAmountRegex.firstMatch(line);

      if (match != null) {
        totalAmount =
            match.group(0)?.trim(); // Captura el importe con el símbolo €
        print("Total encontrado: $totalAmount");
        break; // Detener la búsqueda una vez encontrado
      }
    }
  }

  // Devolver el resultado en un mapa
  return {
    "totalAmount": totalAmount,
  };
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
  final int? pageNumber;
  final String? valleyString;
  final String? peakString;
  final String? qrCodeLink;

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
    this.pageNumber,
    this.valleyString,
    this.peakString,
    this.qrCodeLink,
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
    int? pageNumber,
    String? valleyString,
    String? peakString,
    String? qrCodeLink,
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
      pageNumber: pageNumber ?? this.pageNumber,
      valleyString: valleyString ?? this.valleyString,
      peakString: peakString ?? this.peakString,
      qrCodeLink: qrCodeLink ?? this.qrCodeLink,
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

// Función para normalizar texto (elimina tildes y convierte a minúsculas)
String normalizeText(String text) {
  return removeDiacritics(text).toLowerCase();
}

Map<String, String?> extractContractDetails(String line, List<String> lines) {
  // Variables para almacenar los valores encontrados
  String? puntaValue;
  String? valleValue;
  String? contractType;

  // Normalización de las frases clave
  final powerContracted = normalizeText("Potencias contratadas");
  final contractName = normalizeText("Contrato de mercado libre:");

  // Iterar sobre las líneas
  for (final line in lines) {
    final normalizedLine = normalizeText(line);

    // Buscar el tipo de contrato
    if (normalizedLine.contains(contractName)) {
      final match =
          RegExp(r'contrato de mercado libre:\s*(.+)', caseSensitive: false)
              .firstMatch(normalizedLine);

      if (match != null) {
        contractType = match
            .group(1)
            ?.trim(); // Extraer el contenido después de los dos puntos
        print("Tipo de contrato encontrado: $contractType");
      }
    }

    // Buscar potencias contratadas
    if (normalizedLine.contains(powerContracted)) {
      final match = RegExp(r'punta\s([\d.,]+\s*kW);?\s*valle\s([\d.,]+\s*kW);?',
              caseSensitive: false)
          .firstMatch(normalizedLine);

      if (match != null) {
        puntaValue = "punta ${match.group(1)}";
        valleValue = "valle ${match.group(2)}";

        print("Encontrado: $puntaValue");
        print("Encontrado: $valleValue");
      }
    }
  }

  // Devolver un mapa con los valores encontrados
  return {
    "contractType": contractType,
    "punta": puntaValue,
    "valle": valleValue,
  };
}

String? extractCompanyInfo(String pdfText) {
  final cifRegex = RegExp(r'\bCIF\s[A-Z]\d{8}\b', caseSensitive: false);
  final nameRegex = RegExp(
      r'[A-Za-z\s.,ñÑáéíóúÁÉÍÓÚ\-]+s\.a\.?(\s+unipersonal)?',
      caseSensitive: false);

  final cifMatch = cifRegex.firstMatch(pdfText);
  final nameMatch = nameRegex.firstMatch(pdfText);

  if (cifMatch != null && nameMatch != null) {
    return nameMatch.group(0)?.trim();
  }

  return null;
}
