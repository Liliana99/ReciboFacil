import 'dart:io';
import 'dart:ui' as ui;
import 'package:diacritic/diacritic.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:interactive_viewer_2/interactive_viewer_2.dart';
import 'package:path_provider/path_provider.dart';
// Dependiendo de librerías PDF y OCR
import 'package:pdf_render/pdf_render.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:recibo_facil/src/features/home/presentation/blocs/home_cubit.dart';

class PdfOcrCropScreen extends StatefulWidget {
  final String pdfPath;
  final int pageNumber;

  const PdfOcrCropScreen({
    Key? key,
    required this.pdfPath,
    required this.pageNumber,
  }) : super(key: key);

  @override
  State<PdfOcrCropScreen> createState() => _PdfOcrCropScreenState();
}

class _PdfOcrCropScreenState extends State<PdfOcrCropScreen> {
  String ocrText = '';
  bool isLoading = true;
  late Future<ui.Image?> _myFuture;
  Uint8List? croppedImageBytes;

  @override
  void initState() {
    super.initState();
    // Asignar el Future *antes* de que se llame build() por primera vez
    _myFuture = _processPdfAndShowGraph();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image?>(
      future: _myFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Text('No se pudo extraer la imagen');
        }

        // Si todo va bien, snapshot.data contiene el ui.Image
        return croppedImageBytes != null
            ? InteractiveViewer(
                child: Image.memory(
                  croppedImageBytes!,
                  fit: BoxFit.scaleDown, // Ajusta el tamaño según lo necesites
                ),
              )
            : Text("No hay imagen disponible");
      },
    );
  }

  Future<ui.Image?> _processPdfAndCropGraph() async {
    try {
      // 1) Abrir PDF y renderizar la página
      final pdfDoc = await PdfDocument.openFile(widget.pdfPath);
      final pdfPage = await pdfDoc.getPage(widget.pageNumber);

      final pageImage = await pdfPage.render(
        width:
            pdfPage.width.toInt() * 4, // Aumentar resolución para mejor calidad
        height: pdfPage.height.toInt() * 4,
      );
      await pageImage.createImageIfNotAvailable();
      final ui.Image? fullImage = pageImage.imageIfAvailable;

      if (fullImage == null) {
        print("No se pudo renderizar la página PDF.");
        return null;
      }

      // 2) Convertir a InputImage para OCR
      final byteData =
          await fullImage.toByteData(format: ui.ImageByteFormat.png);
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/page_${widget.pageNumber}.png';
      final file = File(tempPath);
      await file.writeAsBytes(byteData!.buffer.asUint8List());

      final inputImage = InputImage.fromFilePath(tempPath);
      final textRecognizer = TextRecognizer();
      final recognizedText = await textRecognizer.processImage(inputImage);
      textRecognizer.close();

      // 3) Buscar el bloque que contenga "kWh Evolución del consumo"
      final String targetText = "evolucion del consumo";
      Rect? regionRect;

      for (TextBlock block in recognizedText.blocks) {
        final blockTextLower = removeDiacritics(block.text).toLowerCase();
        final targetTextLower = removeDiacritics(targetText).toLowerCase();

        if (blockTextLower.contains(targetTextLower)) {
          regionRect = block.boundingBox;
          break;
        }
      }

      if (regionRect == null) {
        print("No se encontró el bloque con \"$targetText\".");
        return null;
      }

      // 4) Llamar al método para recortar el gráfico basado en el texto detectado
      final ui.Image croppedGraph = await _cropBottom75Percent(fullImage);

      // 5) Retornar la imagen del gráfico recortado
      return croppedGraph;
    } catch (e) {
      print("Error al procesar y recortar el gráfico: $e");
      return null;
    }
  }

  Future<ui.Image> _cropGraphFromPdf(ui.Image source, Rect regionRect) async {
    // Asegúrate de escalar las coordenadas si es necesario
    final Rect extendedRegion = Rect.fromLTRB(
      regionRect.left, // Mantén el inicio izquierdo del texto detectado
      regionRect.top, // Mantén la parte superior del texto
      source.width.toDouble(), // Extiende hasta el borde derecho de la página
      source.height.toDouble() *
          0.8, // Extiende hacia abajo para capturar el gráfico
    );

    // Validar que la región extendida esté dentro de los límites de la imagen
    final Rect validRegion = Rect.fromLTRB(
      extendedRegion.left.clamp(0, source.width.toDouble()),
      extendedRegion.top.clamp(0, source.height.toDouble()),
      extendedRegion.right.clamp(0, source.width.toDouble()),
      extendedRegion.bottom.clamp(0, source.height.toDouble()),
    );

    // Crear el canvas para recortar
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Dibujar la región en un nuevo canvas
    final Rect src = validRegion;
    final Rect dst = Rect.fromLTWH(0, 0, validRegion.width, validRegion.height);
    canvas.drawImageRect(source, src, dst, Paint());

    // Generar la imagen recortada
    final picture = recorder.endRecording();
    return await picture.toImage(
      validRegion.width.toInt(),
      validRegion.height.toInt(),
    );
  }

  Future<Uint8List> _convertUiImageToBytes(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<ui.Image?> _processPdfAndShowGraph() async {
    try {
      final ui.Image? croppedGraph = await _processPdfAndCropGraph();
      final homeCubit = context.read<HomeCubit>();
      if (croppedGraph != null) {
        final bytes = await _convertUiImageToBytes(croppedGraph);
        homeCubit.updateImageVisible(true);
        setState(() {
          croppedImageBytes = bytes; // Almacena la imagen recortada
        });
        return croppedGraph;
      } else {
        print("No se pudo recortar el gráfico.");
      }
    } catch (e) {
      print("Error al procesar la imagen: $e");
    }
    return null;
  }

  Future<ui.Image> _cropBottom75Percent(ui.Image source) async {
    // Definir el Rect que abarca el 75% inferior del documento
    final Rect graphRegion = Rect.fromLTRB(
      source.width * 0.55, // Desde el borde izquierdo
      source.height * 0.40, // Comienza en el 25% de la altura desde arriba
      source.width.toDouble(), // Hasta el borde derecho
      source.height.toDouble(), // Hasta el final de la página
    );

    // Crear el canvas para recortar
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Dibujar la región recortada
    final Rect src = graphRegion;
    final Rect dst = Rect.fromLTWH(0, 0, graphRegion.width, graphRegion.height);
    canvas.drawImageRect(source, src, dst, Paint());

    // Generar la imagen recortada
    final picture = recorder.endRecording();
    return await picture.toImage(
      graphRegion.width.toInt(),
      graphRegion.height.toInt(),
    );
  }
}
