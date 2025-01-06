import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:recibo_facil/src/home/blocs/home_cubit.dart';
import 'package:recibo_facil/src/home/blocs/home_state_cubit.dart';
import 'package:recibo_facil/src/home/utils/custom_extension_sized.dart';
import 'package:recibo_facil/src/home/utils/recognized_text.dart';
import 'package:recibo_facil/src/home/widgets/custom_buttom_loader.dart';

import 'package:recibo_facil/src/home/widgets/info_card_container.dart';
import 'package:recibo_facil/src/home/widgets/responsive_page.dart';
import 'package:recibo_facil/src/home/widgets/shimmer_home.dart';

import '../../../const/colors_constants.dart';
import '../../services/service_locator.dart';

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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ResponsiveHomePage(
      appBar: AppBar(
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
      body: BlocProvider(
        create: (context) => getIt<HomeCubit>(),
        child: BlocBuilder<HomeCubit, HomeStateCubit>(
          builder: (context, state) {
            final isMultiline = _isMultiline(
              state.month ?? '',
              TextStyle(fontSize: 6, color: Colors.blue),
              size.width * 0.01,
              2,
            );

            return ListView(
              children: [
                if (state.isScanning!)
                  ShimmerReaderHomePage(isScanned: isScanned, size: size),
                if (state.scannedText != null ||
                    state.totalAmount != null ||
                    state.month != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InfoCardContainer(
                          size: size,
                          isMultiline: isMultiline,
                          icon: Icon(
                            Icons.euro,
                            size: 40,
                            color: Colors.blue,
                          ),
                          label: 'Total a Pagar',
                          value: state.totalAmount ?? '',
                          color: ColorsApp.baseColorApp,
                        ),
                        InfoCardContainer(
                          size: size,
                          isMultiline: isMultiline,
                          icon: Image.asset(
                            'assets/iconos/calendar.png',
                            width: 30,
                            height: 30,
                            color: Colors.blue,
                          ),
                          label: 'Mes Facturado',
                          value: state.month ?? '',
                          color: ColorsApp.baseColorApp,
                        ),
                      ],
                    ),
                  ),
                if (state.scannedText == null && !state.isScanning!)
                  Column(
                    children: [
                      InfoCard2(
                        onPressed: () {},
                        width: size.width * 0.95,
                        child: Row(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: SizedBox(
                                height: size.height * 0.035,
                                child: Image.asset(
                                  'assets/iconos/gallery.png',
                                ),
                              ),
                            ),
                            SizedBox(
                              width: size.width * 0.05,
                            ),
                            Text(
                              'Seleccionar desde Galería',
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.arrow_forward_ios_outlined,
                                  color: Colors.black54,
                                )),
                          ],
                        ),
                      ),
                      50.ht,
                      CustomButton(
                        onPressed: _selectFromGallery,
                        text: 'Seleccionar desde Galería',
                        iconPath: 'assets/iconos/gallery.png',
                      ),
                      50.ht,
                      CustomButton(
                        onPressed: _takePhoto,
                        text: 'Escanear factura',
                        iconPath: 'assets/iconos/camera.png',
                      ),
                      50.ht,
                      CustomButton(
                        onPressed: () async {
                          final homeCubit = context.read<HomeCubit>();
                          await selectAndOpenPdf(context, homeCubit);
                        },
                        text: 'Seleccionar PDF',
                        iconPath: 'assets/iconos/pdf.png',
                        iconColor: Colors
                            .red, // Cambiar el color del icono para este botón
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.30,
                      ),
                    ],
                  ),
              ],
            );
          },
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
