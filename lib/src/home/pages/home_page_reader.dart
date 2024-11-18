import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:recibo_facil/src/home/utils/recognized_text.dart';
import 'package:recibo_facil/src/home/widgets/graphic.dart';
import 'package:recibo_facil/src/home/widgets/shimmer.dart';
import 'package:recibo_facil/src/home/widgets/title_home.dart';

class HomePageReader extends StatefulWidget {
  static const routeName = '/home_page';

  @override
  State<HomePageReader> createState() => _HomePageReaderState();
}

class _HomePageReaderState extends State<HomePageReader> {
  String scannedText = "";
  bool isScanned = false;
  final ImagePicker _picker = ImagePicker();
  String totalAmount = '';
  String month = '';
  File? _selectedImage;
  late PdfDocument document;
  String progressMessage = "Cargando documento...";

  late Timer timer;
  DateTime currentTime = DateTime.now();

  Future<void> _loadPdf(final String pdfPath) async {
    final docRef = await PdfDocumentRefFile(pdfPath);
    document = await docRef.loadDocument(
      (int pageNumber, [int? pageCount]) {
        // Progreso de la carga
        setState(() {
          isScanned = true;
          progressMessage = pageCount != null
              ? "Cargando página $pageNumber de $pageCount..."
              : "Cargando página $pageNumber...";
        });
        print(progressMessage);
      },
      (totalPages, loadedPages, duration) {
        // Reporte final
        setState(() {
          progressMessage =
              "Cargado: $loadedPages / $totalPages páginas en $duration.";
        });
        print(progressMessage);
        isScanned = false;
      },
    );

    print("PDF cargado con ${document.pages.length} páginas.");
  }

  Future<void> _performOCR(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final TextRecognizer textRecognizer = await TextRecognizer();

    try {
      setState(() {
        isScanned = true;
      });
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      print('texto :${recognizedText.blocks}');
      totalAmount = await processRecognizedText(recognizedText) ?? '';
      month = await processBillingMonth(recognizedText) ?? '';

      setState(() {
        scannedText = recognizedText.text;
        totalAmount = totalAmount;
        month = month;
        isScanned = false;
      });
    } finally {
      textRecognizer.close();
    }
  }

  Future<void> searchTextOnPdf(String query) async {
    if (document.pages.isEmpty) {
      print("El documento no contiene páginas.");
      return;
    }

    print(
        "Iniciando búsqueda para '$query' en ${document.pages.length} páginas.");

    for (int page = 1; page <= document.pages.length; page++) {
      print("Buscando en la página $page...");
      final pageText = await document.pages[page - 1].loadText();

      if (pageText != null) {
        final lines = pageText.fullText.split('\n');
        for (final line in lines) {
          if (line.contains(query)) {
            print("Término encontrado en la página $page: $line");
            setState(() {
              scannedText = pageText.fullText;
              if (query == "Periodo de facturación") {
                month = extractBillingPeriod(line) ?? '';
              } else {
                totalAmount = getValueWithCurrency(line) ?? '';
              }
            });
            break;
          }
        }
      } else {
        print("No se pudo cargar el texto de la página $page.");
      }
    }

    print("Búsqueda finalizada.");
  }

  Future<void> _takePhoto() async {
    try {
      final List<String>? processedImages =
          await CunningDocumentScanner.getPictures();
      if (processedImages != null && processedImages.isNotEmpty) {
        await _recognizeText(processedImages.first);
        setState(() {
          isScanned = false;
        });
      }
    } on Exception catch (e) {
      setState(() {
        scannedText = 'Error while importing document: $e';
      });
    }
  }

  Future<void> _selectFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
      await _performOCR(_selectedImage!);
      // Navigator.of(context).push(MaterialPageRoute(
      //   builder: (context) => PdfSearchPage(pdfPath: image.path),
      // ));
    }
  }

  Future<void> _recognizeText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer();

    try {
      final recognizedText = await textRecognizer.processImage(inputImage);
      await processRecognizedText(recognizedText);
      setState(() {
        scannedText = recognizedText.text;
      });
      if (scannedText.isNotEmpty) {
        print(scannedText);
      }
    } catch (e) {
      setState(() {
        scannedText = 'Error while recognizing text: \$e';
      });
    } finally {
      textRecognizer.close();
    }
  }

  bool _isMultiline(
      String text, TextStyle style, double maxWidth, int maxLines) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: maxWidth);
    print('excede? ${textPainter.didExceedMaxLines}');
    return textPainter.didExceedMaxLines;
  }

  Future<void> selectAndOpenPdf(
    BuildContext context,
  ) async {
    // Seleccionar archivo PDF
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // Limitar a archivos PDF
    );

    if (result != null) {
      String? pdfPath = result.files.single.path;
      String query = "a pagar";
      setState(() {
        isScanned = true;
      });

      if (pdfPath != null) {
        await _loadPdf(pdfPath);
        for (int i = 0; i < 2; i++) {
          if (i == 1) {
            query = "Periodo de facturación";
          }
          if (mounted) {
            await searchTextOnPdf(query);
          }
        }
        setState(() {
          isScanned = false;
        });

        // Navegar al widget PdfSearchPage con la ruta del PDF
        // Navigator.of(context).push(MaterialPageRoute(
        //   builder: (context) => PdfSearchPage(pdfPath: pdfPath),
        // ));
      }
    } else {
      // Usuario canceló la selección
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selección de archivo cancelada')),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: ReaderHomeTitle(),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.arrow_back_ios,
              ),
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ListView(
              //  crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                if (isScanned)
                  Shimmer(
                    linearGradient: shimmerGradient,
                    child: ShimmerLoading(
                      isLoading: isScanned,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 100,
                          ),
                          Container(
                            height: size.height * 0.25,
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(50)),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            height: size.height * 0.25,
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(50)),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (scannedText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Stack(
                      children: [
                        Clock12Hour(),
                        // GraphicCustom(
                        //     // clock: AnalogClock(currentTime: currentTime),
                        //     ),
                        // Positioned(
                        //   top: 265,
                        //   left: 100,
                        //   child: Column(
                        //     children: [
                        //       Icon(Icons.nightlight_round,
                        //           color: const Color.fromARGB(255, 62, 156, 58),
                        //           size: 30),
                        //       SizedBox(height: 10),
                        //       Text(
                        //         "Horas Nocturnas",
                        //         style: TextStyle(
                        //             color: Colors.black,
                        //             fontWeight: FontWeight.bold),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                if (scannedText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: size.width * 0.40,
                          height: _isMultiline(
                                  month,
                                  TextStyle(fontSize: 6, color: Colors.blue),
                                  30,
                                  3)
                              ? size.height * 0.30
                              : size.height * 0.20,
                          child: InfoCard(
                            icon: Icon(
                              Icons.euro,
                              size: 40,
                              color: Colors.blue,
                            ),
                            label: 'Total a Pagar',
                            value: totalAmount,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.40,
                          height: _isMultiline(
                                  month,
                                  TextStyle(fontSize: 6, color: Colors.blue),
                                  30,
                                  3)
                              ? size.height * 0.30
                              : size.height * 0.20,
                          child: InfoCard(
                            icon: Image.asset(
                              'assets/iconos/calendar.png',
                              width: 30,
                              height: 30,
                              color: Colors.blue,
                            ),
                            label: 'Mes Facturado',
                            value: month,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 20),
                if (scannedText.isEmpty && !isScanned)
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 120,
                          child: ElevatedButton(
                            onPressed: _selectFromGallery,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color(0xFF81D4FA), // Light blue button
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40.0),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Wrap(
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    height: 50,
                                    width: 50,
                                    child: Image.asset(
                                        'assets/iconos/gallery.png',
                                        color: Colors.white),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Seleccionar desde Galería',
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 50),
                        SizedBox(
                          height: 120,
                          child: ElevatedButton(
                            onPressed: _takePhoto,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF81D4FA),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40.0),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Wrap(
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    height: 50,
                                    width: 50,
                                    child: Image.asset(
                                        'assets/iconos/camera.png',
                                        color: Colors.white),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Escanear factura',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 50),
                        SizedBox(
                          height: 120,
                          child: ElevatedButton(
                            onPressed: () {
                              selectAndOpenPdf(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color(0xFF81D4FA), // Light blue button
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40.0),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Wrap(
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    height: 50,
                                    width: 50,
                                    child: Image.asset('assets/iconos/pdf.png',
                                        color: Colors.red),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Seleccionar PDF',
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.30,
                        ),
                      ],
                    ),
                  ),
                if (isScanned)
                  SizedBox(
                    height: 200,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final Widget icon;
  final String label;
  final String value;
  final Color color;

  InfoCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  bool _isMultiline(
      String text, TextStyle style, double maxWidth, int maxLines) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: maxWidth);
    print('excede? ${textPainter.didExceedMaxLines}');
    return textPainter.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        children: [
          icon,
          SizedBox(height: 8),
          Text(label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          Wrap(
            children: [
              Text(value,
                  textAlign: TextAlign.left,
                  maxLines: _isMultiline(
                          value, TextStyle(fontSize: 6, color: color), 30, 3)
                      ? 4
                      : 2,
                  style: TextStyle(fontSize: 18, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}

class EnergyTip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  EnergyTip({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 16)),
      ],
    );
  }
}

class AnalogClock extends StatelessWidget {
  final DateTime currentTime;

  AnalogClock({required this.currentTime});

  @override
  Widget build(BuildContext context) {
    double hourAngle =
        (currentTime.hour + currentTime.minute / 60) * 15; // 24 horas
    double minuteAngle = currentTime.minute * 6;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Dibuja los números del reloj alrededor del borde (1 a 24)
        for (int i = 1; i <= 24; i++)
          Transform.translate(
            offset: Offset(
              70 * cos((i * 15 - 90) * pi / 180), // 15 grados por número
              70 * sin((i * 15 - 90) * pi / 180),
            ),
            child: Text(
              '$i',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        // Aguja de la hora
        Transform.rotate(
          angle: hourAngle * (pi / 180),
          child: Container(
            width: 4,
            height: 40,
            color: Colors.black,
          ),
        ),
        // Aguja del minuto
        Transform.rotate(
          angle: minuteAngle * (pi / 180),
          child: Container(
            width: 3,
            height: 60,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
}
