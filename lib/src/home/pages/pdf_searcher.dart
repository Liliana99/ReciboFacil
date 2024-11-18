import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class PdfSearchPage extends StatefulWidget {
  final String pdfPath;

  const PdfSearchPage({required this.pdfPath, Key? key}) : super(key: key);

  @override
  _PdfSearchPageState createState() => _PdfSearchPageState();
}

class _PdfSearchPageState extends State<PdfSearchPage> {
  final controller = PdfViewerController();
  late final PdfTextSearcher textSearcher;

  @override
  void initState() {
    super.initState();

    textSearcher = PdfTextSearcher(controller)..addListener(_onSearchUpdate);

    print("Listener registrado.");
    print("Cargando archivo PDF desde: ${widget.pdfPath}");
  }

  @override
  void dispose() {
    textSearcher.removeListener(_onSearchUpdate);
    textSearcher.dispose();
    super.dispose();
  }

  Future<void> _onSearchUpdate() async {
    if (!mounted) return;

    final matches = textSearcher.matches;
    print(
        "Listener activado. Número de coincidencias encontradas: ${matches.length}");

    if (matches.isEmpty) {
      print("No se encontraron coincidencias.");
    } else {
      for (final match in matches) {
        print("Página: ${match.pageNumber}");
        for (final fragment in match.fragments) {
          print("Texto encontrado: ${fragment.text}");
        }
      }
    }
  }

  // Future<void> searchAcrossAllPages(String query) async {
  //   final int? totalPages = await controller.useDocument(
  //     (document) async {
  //       return document.pages.length;
  //     },
  //   );

  //   if (totalPages == null || totalPages == 0) {
  //     print("No se pudo obtener el número de páginas del PDF.");
  //     return;
  //   }

  //   print("Iniciando búsqueda para '$query' en $totalPages páginas.");

  //   for (int page = 1; page <= totalPages; page++) {
  //     print("Buscando en la página $page...");
  //     final pageText = await textSearcher.loadText(pageNumber: page);

  //     if (pageText != null) {
  //       // Verifica si el texto de la página contiene el término de búsqueda

  //       if (pageText.fullText.contains(query)) {

  //         print(
  //             "Término encontrado en la página $page: ${pageText.pageNumber} ");
  //         break;
  //       } else {
  //         print("El término no se encontró en la página $page.");
  //       }
  //     } else {
  //       print("No se pudo cargar el texto de la página $page.");
  //     }
  //   }

  //   print("Búsqueda finalizada.");
  // }

  Future<void> searchAcrossAllPages(String query) async {
    final int? totalPages = await controller.useDocument(
      (document) async {
        return document.pages.length;
      },
    );

    if (totalPages == null) {
      print("No se pudo obtener el número de páginas del PDF.");
      return;
    }

    print("Iniciando búsqueda para '$query' en $totalPages páginas.");

    for (int page = 1; page <= totalPages; page++) {
      print("Buscando en la página $page...");
      final pageText = await textSearcher.loadText(pageNumber: page);

      if (pageText != null) {
        final lines = pageText.fullText.split('\n');

        // Buscar la línea que contiene el término
        for (final line in lines) {
          if (line.contains(query)) {
            print("Término encontrado en la página $page: $line");
            break; // Salir del bucle si se encuentra el término
          }
        }
      } else {
        print("No se pudo cargar el texto de la página $page.");
      }
    }

    print("Búsqueda finalizada.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buscar en PDF'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              await searchAcrossAllPages("a pagar"); // Cambia por tu consulta
            },
          ),
        ],
      ),
      body: PdfViewer.file(
        widget.pdfPath,
        controller: controller,
        params: PdfViewerParams(
          pagePaintCallbacks: [textSearcher.pageTextMatchPaintCallback],
        ),
      ),
    );
  }
}

List<String> _combineTextFragmentsIntoLines(
    List<PdfPageTextFragment> fragments) {
  // Combina fragmentos en líneas según su posición en el PDF
  final Map<double, StringBuffer> linesMap = {};

  for (final fragment in fragments) {
    final lineY = fragment.bounds.top; // Coordenada Y de la línea
    linesMap
        .putIfAbsent(lineY, () => StringBuffer())
        .write('${fragment.text} ');
  }

  // Ordenar las líneas por su posición Y
  final sortedKeys = linesMap.keys.toList()..sort();

  return sortedKeys.map((y) => linesMap[y]!.toString().trim()).toList();
}
