import 'package:pdfrx/pdfrx.dart';
import 'package:recibo_facil/src/home/utils/recognized_text.dart';

class PdfRepository {
  Future<ResponsePdfReader?> searchTextOnPdf(
      PdfDocument document, String query) async {
    if (document.pages.isEmpty) {
      print("El documento no contiene páginas.");
      return ResponsePdfReader(scannedText: 'No se encontró el término');
    }

    Map<String, String> results = {};

    print(
        "Iniciando búsqueda para '$query' en ${document.pages.length} páginas.");

    for (int page = 1; page <= document.pages.length; page++) {
      final pageText = await document.pages[page - 1].loadText();

      if (pageText != null) {
        final lines = pageText.fullText.split('\n');
        for (final line in lines) {
          if (line.contains(query)) {
            print("Término encontrado en la página $page: $line");

            results['scannedText'] = pageText.fullText;
            if (query == "Periodo de facturación") {
              return ResponsePdfReader(
                  scannedText: pageText.fullText,
                  month: extractBillingPeriod(line));
            } else {
              return ResponsePdfReader(
                  scannedText: pageText.fullText,
                  totalAmount: getValueWithCurrency(line));
            }
          }
        }
      } else {
        print("No se pudo cargar el texto de la página $page.");
      }
    }

    print("Búsqueda finalizada.");
    return null;
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
}
