import 'package:pdfrx/pdfrx.dart';
import 'package:recibo_facil/src/home/utils/recognized_text.dart';

class PdfRepository {
  Future<ResponsePdfReader?> searchTextOnPdf(
      PdfDocument document, String query) async {
    if (document.pages.isEmpty) {
      print("El documento no contiene páginas.");
      return ResponsePdfReader(scannedText: 'No se encontró el término');
    }

    var response = ResponsePdfReader(scannedText: '');

    print(
        "Iniciando búsqueda para '$query' en ${document.pages.length} páginas.");

    // Iterar por todas las páginas del documento
    for (int page = 1; page <= document.pages.length; page++) {
      final pageText = await document.pages[page - 1].loadText();

      if (pageText != null) {
        final lines = pageText.fullText.split('\n');

        // Iterar por todas las líneas de la página
        for (final line in lines) {
          if (line.contains(query)) {
            print("Término encontrado en la página $page: $line");

            // Acumular valores según el query y actualizar `response` usando `copyWith`
            if (query == "Periodo de facturación" && response.month == null) {
              response = response.copyWith(
                month: extractBillingPeriod(line),
              );
            } else if (query == "a pagar" && response.totalAmount == null) {
              response = response.copyWith(
                totalAmount: getValueWithCurrency(line),
              );
            }

            // Acumular el texto escaneado
            response = response.copyWith(
              scannedText: response.scannedText.isEmpty
                  ? line
                  : '${response.scannedText}\n$line',
            );
          }
        }
      } else {
        print("No se pudo cargar el texto de la página $page.");
      }
    }

    print("Búsqueda finalizada.");

    // Retornar la respuesta completa después de procesar todas las páginas
    if (response.month != null || response.totalAmount != null) {
      return response;
    } else {
      return null; // Si no se encontraron valores relevantes, retornar null
    }
  }
}

class ResponsePdfReader {
  final String scannedText;
  final String? month;
  final String? totalAmount;

  ResponsePdfReader({
    required this.scannedText,
    this.month,
    this.totalAmount,
  });

  ResponsePdfReader copyWith({
    String? scannedText,
    String? month,
    String? totalAmount,
  }) {
    return ResponsePdfReader(
      scannedText: scannedText ?? this.scannedText,
      month: month ?? this.month,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}
