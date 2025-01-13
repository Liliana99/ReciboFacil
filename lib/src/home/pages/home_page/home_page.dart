import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:recibo_facil/const/assets_constants.dart';
import 'package:recibo_facil/src/features/home/presentation/blocs/home_cubit.dart';
import 'package:recibo_facil/src/features/home/presentation/blocs/home_state_cubit.dart';
import 'package:recibo_facil/src/home/pages/home_page_animation.dart';

import 'package:recibo_facil/src/home/utils/recognized_text.dart';
import 'package:recibo_facil/src/home/widgets/body_reader_initial.dart';
import 'package:recibo_facil/src/home/widgets/body_result_pdf.dart';

import 'package:recibo_facil/src/home/widgets/responsive_page.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../const/colors_constants.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home_page';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  bool isSeraching = false;

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

  void updateIsSeraching() => setState(() {
        isSeraching = !isSeraching;
      });

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

    // Realiza el layout para obtener la información de tamaño.
    textPainter.layout(maxWidth: maxWidth);

    // Obtener la altura de una sola línea.
    final lineHeight = textPainter.preferredLineHeight;

    // Calcula cuántas líneas ocupa el texto con la altura total.
    final numLines = (textPainter.height / lineHeight).ceil();

    // Verifica si el número de líneas excede el límite máximo.
    return numLines > 1;
  }

  Future<void> selectAndOpenPdf(
      BuildContext context, HomeCubit homeCubit) async {
    // Seleccionar el archivo PDF
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      String? pdfPath = result.files.single.path;

      if (pdfPath != null) {
        // Actualizar el estado de escaneo a activo
        homeCubit.updateIsScanning(true);

        // Cargar el documento PDF
        await _loadPdf(pdfPath);

        if (mounted) {
          // Ejecutar búsqueda de términos en el documento
          await homeCubit
              .searchPdf(document, ["a pagar", "Periodo de facturación"]);

          // Actualizar el estado para indicar que el escaneo ha terminado
          homeCubit.updateIsScanning(false);
        }
      }
    } else {
      // Usuario canceló la selección de archivo
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

  void goToPage(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            HomePageAnimation(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // Desde la derecha
          const end = Offset.zero; // A la posición actual
          const curve = Curves.easeInOut;

          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  Future<void> _selectAndOpenPdf(
      BuildContext context, HomeCubit homeCubit) async {
    // Seleccionar el archivo PDF
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      String? pdfPath = result.files.single.path;

      if (pdfPath != null) {
        // Actualizar el estado de escaneo a activo
        homeCubit.updateIsScanning(true);
        homeCubit.updateIsFromPdf(true);
        homeCubit.updatePathFile(File(pdfPath));

        // Cargar el documento PDF
        final document = await homeCubit.loadPdf(pdfPath);

        // Ejecutar búsqueda de términos en el documento
        await homeCubit.searchPdf(document, [
          "a pagar",
          "Periodo de facturación",
          "nº factura",
          "Potencias contratadas",
          "CUPS",
          "contrato",
          "kwh evolucion del consumo",
        ]);

        // Actualizar el estado para indicar que el escaneo ha terminado
        homeCubit.updateIsScanning(false);
      }
    } else {
      if (mounted) {
        // Usuario canceló la selección de archivo
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selección de archivo cancelada')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    context.read<HomeCubit>();
    return BlocBuilder<HomeCubit, HomeStateCubit>(
      builder: (context, state) {
        return ResponsiveHomePage(
          body: (state.isScanning!)
              ? SizedBox(
                  height: size.height * 0.01,
                  width: size.width * 0.85,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[400]!,
                      highlightColor: Colors.grey[200]!,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(
                              50), // Bordes redondeados como el botón original
                        ),
                        alignment: Alignment.center, // Centrar el texto
                        child: SizedBox(
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[400]!,
                            highlightColor: Colors.grey[200]!,
                            child: Text(
                              'Cargando...',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : ListView(
                  children: [
                    if (state.isFromPdf!)
                      BodyResultPdf(
                        size: size,
                        selectAndOpenPdf: selectAndOpenPdf,
                        stateCubit: state,
                      ),
                    if (!state.isFromPdf!)
                      Stack(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.70,
                            color: Colors.white,
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height,
                          ),
                          Positioned(
                            top: size.height *
                                0.40, // Ajusta esta altura según lo necesites
                            left: 0,
                            right: 0,
                            child: SizedBox(
                              height: size.height * 0.30,
                              width: size.width,
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: BodyReaderInitial(
                                  size: size,
                                  selectAndOpenPdf: (context, homeCubit) =>
                                      _selectAndOpenPdf(context, homeCubit),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: size.width * 0.04,
                            left: size.width * 0.06,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Recibo Fácil',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: LottieBuilder.asset(
                                        Assets.billEnergyAnimation,
                                        fit: BoxFit.contain),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: size.height * 0.15,
                            right: size.width * 0.06,
                            left: size.width * 0.06,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Seleccione el metodo para cargar su factura de la energia',
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: ColorsApp.subTitleColor),
                              ),
                            ),
                          )
                        ],
                      )
                  ],
                ),
        );
      },
    );
  }
}

class InfoCard extends StatelessWidget {
  final Widget icon;
  final String label;
  final String value;
  final Color color;
  final Size size;
  final bool isMultiline;

  InfoCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color,
      required this.size,
      required this.isMultiline});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width * 0.01,
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
              Text(
                value,
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: isMultiline ? 12 : 14,
                    color: color,
                    fontWeight: FontWeight.w600),
              ),
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

class InfoCard2 extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final VoidCallback onPressed;
  const InfoCard2(
      {super.key,
      required this.child,
      required this.width,
      this.height,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
          width: width,
          height: height,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: child),
    );
  }
}
