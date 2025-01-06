import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:recibo_facil/src/home/blocs/home_state_cubit.dart';

class PdfInteractiveViewer extends StatefulWidget {
  final String pdfFilePath;
  final HomeStateCubit cubitState;

  const PdfInteractiveViewer(
      {Key? key, required this.pdfFilePath, required this.cubitState})
      : super(key: key);

  @override
  _PdfInteractiveViewerState createState() => _PdfInteractiveViewerState();
}

class _PdfInteractiveViewerState extends State<PdfInteractiveViewer> {
  late PdfDocument _pdfDocument;
  List<ui.Image> _pageImages = [];
  bool _isLoading = true;
  bool _isZooming = false; // Controla si el usuario está haciendo zoom.

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      _pdfDocument = await PdfDocument.openFile(widget.pdfFilePath);

      List<ui.Image> pageImages = [];
      for (int i = 1; i <= _pdfDocument.pageCount; i++) {
        final page = await _pdfDocument.getPage(i);
        final renderedPage = await page.render(
          width: page.width.toInt(),
          height: page.height.toInt(),
        );
        if (renderedPage != null) {
          final uiImage = await _convertPixelsToImage(
            renderedPage.pixels,
            renderedPage.width,
            renderedPage.height,
          );
          pageImages.add(uiImage);
        }
      }

      setState(() {
        _pageImages = pageImages;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar el PDF: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<ui.Image> _convertPixelsToImage(
      Uint8List pixels, int width, int height) async {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      pixels,
      width,
      height,
      ui.PixelFormat.rgba8888,
      (image) => completer.complete(image),
    );
    return completer.future;
  }

  @override
  void dispose() {
    _pdfDocument.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onScaleStart: (_) {
        setState(() {
          _isZooming = true; // Deshabilitar el desplazamiento del PageView.
        });
      },
      onScaleEnd: (_) {
        setState(() {
          _isZooming = false; // Rehabilitar el desplazamiento del PageView.
        });
      },
      child: PageView.builder(
        physics: _isZooming
            ? const NeverScrollableScrollPhysics() // Desactiva el scroll durante el zoom.
            : const BouncingScrollPhysics(), // Activa el scroll cuando no hay zoom.
        scrollDirection: Axis.horizontal,
        itemCount: _pageImages.length,
        itemBuilder: (context, index) {
          final uiImage = _pageImages[index];
          // Si es la primera página, muestra el contenedor personalizado
          //  if (index == 0) {
          if (index == 0) {
            // Mostrar el diseño personalizado para la primera página
            return InteractiveViewer(
              panEnabled: true,
              minScale: 1.0,
              maxScale: 4.0,
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: RawImage(
                    image: _pageImages[
                        0]), // Muestra la primera página renderizada
              ),
            );
          }

          //}

          return InteractiveViewer(
            panEnabled: true,
            minScale: 1.0,
            maxScale: 4.0,
            child: RawImage(image: uiImage),
          );
        },
      ),
    );
  }
}

class PdfPageImage extends StatefulWidget {
  final String pdfFilePath;
  final int pageNumber; // Número de página que deseas mostrar.

  const PdfPageImage({
    Key? key,
    required this.pdfFilePath,
    required this.pageNumber,
  }) : super(key: key);

  @override
  _PdfPageImageState createState() => _PdfPageImageState();
}

class _PdfPageImageState extends State<PdfPageImage> {
  MemoryImage? _pageImage; // Imagen procesada como ImageProvider
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPageImage();
  }

  Future<void> _loadPageImage() async {
    try {
      final pdfDocument = await PdfDocument.openFile(widget.pdfFilePath);
      final page = await pdfDocument.getPage(widget.pageNumber);

      final renderedPage = await page.render(
        width: page.width.toInt(),
        height: page.height.toInt(),
      );

      if (renderedPage != null) {
        setState(() {
          _pageImage = MemoryImage(renderedPage.pixels); // Crea un MemoryImage
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error al cargar la página del PDF: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _pageImage == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Image(
      image: _pageImage!,
      fit: BoxFit.cover,
    );
  }
}

Future<MemoryImage> getImageFromPdf(String pdfFilePath, int pageNumber) async {
  try {
    // Abre el documento PDF
    final pdfDocument = await PdfDocument.openFile(pdfFilePath);
    // Obtiene la página especificada
    final page = await pdfDocument.getPage(pageNumber);

    // Renderiza la página
    final renderedPage = await page.render(
      width: page.width.toInt(),
      height: page.height.toInt(),
    );

    if (renderedPage == null || renderedPage.pixels.isEmpty) {
      throw Exception('No se pudo renderizar la página del PDF');
    }

    // Convierte los píxeles en una MemoryImage
    final memoryImage = MemoryImage(renderedPage!.pixels);

    // Libera los recursos

    return memoryImage; // Devuelve la imagen renderizada como MemoryImage
  } catch (e) {
    print('Error al cargar la imagen del PDF: $e');
    throw Exception('No se pudo renderizar la imagen del PDF');
  }
}

Future<ui.Image> convertPdfPageToImage(
    String pdfFilePath, int pageNumber) async {
  try {
    final pdfDocument = await PdfDocument.openFile(pdfFilePath);
    final page = await pdfDocument.getPage(pageNumber);

    final renderedPage = await page.render(
      width: page.width.toInt(),
      height: page.height.toInt(),
    );

    if (renderedPage == null || renderedPage.pixels.isEmpty) {
      throw Exception('Error al renderizar la página del PDF.');
    }

    final uiImage = await _convertPixelsToImage(
      renderedPage.pixels,
      renderedPage.width,
      renderedPage.height,
    );
    await pdfDocument.dispose();
    return uiImage;
  } catch (e) {
    print('Error al convertir el PDF a ui.Image: $e');
    throw Exception('No se pudo convertir el PDF a ui.Image.');
  }
}

Future<ui.Image> _convertPixelsToImage(
    Uint8List pixels, int width, int height) async {
  final completer = Completer<ui.Image>();
  ui.decodeImageFromPixels(
    pixels,
    width,
    height,
    ui.PixelFormat.rgba8888,
    (image) => completer.complete(image),
  );
  return completer.future;
}
