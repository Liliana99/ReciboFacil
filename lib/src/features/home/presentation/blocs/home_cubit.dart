import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:recibo_facil/src/features/data/repositories/pdf_repository.dart';
import 'package:recibo_facil/src/features/home/presentation/blocs/home_state_cubit.dart';
import 'package:recibo_facil/src/features/data/reconized_text.dart';
import 'dart:html' as html;
import 'package:url_launcher/url_launcher.dart';

import 'utils/get_energy_advice.dart';

class HomeCubit extends Cubit<HomeStateCubit> {
  final PdfRepository _pdfRepository;
  HomeCubit(this._pdfRepository) : super(const HomeStateCubit());

  void updateIsScanning(bool value) => emit(state.copyWith(isScanning: value));

  Future<void> searchPdf(PdfDocument document, List<String> queries) async {
    emit(state.copyWith(isScanning: true));

    try {
      // Ejecutar las búsquedas para cada término en la lista

      final response = await _pdfRepository.searchTextOnPdf(document, queries);

      // Acumular la información relevante
      emit(state.copyWith(
        scannedText: response.scannedText,
        month: response.month ?? state.month,
        totalAmount: response.totalAmount ?? state.totalAmount,
        peak: response.consumptionPunta ?? state.peak,
        billNumber: response.billNumber ?? state.billNumber,
        valley: response.consumptionValle ?? state.valley,
        company: response.company ?? state.company,
        contract: response.contract ?? state.contract,
        cups: response.cups ?? state.cups,
        pageNumber: response.pageNumber ?? state.pageNumber,
        valleyString: response.valleyString ?? state.valleyString,
        peakString: response.peakString ?? state.peakString,
        qrcode: response.qrCodeLink ?? state.qrcode,
        isComplete: true,
        startDate: response.startDate ?? state.startDate,
        endDate: response.endDate ?? state.endDate,
      ));

      // Finalizar el escaneo, si no hay datos relevantes mostrar error
      if (state.scannedText == null && state.totalAmount == null) {
        emit(state.copyWith(
          errorMessage: 'No se encontró información relevante en el documento.',
          isScanning: false,
        ));
      } else {
        emit(state.copyWith(isScanning: false));
      }
    } finally {
      emit(state.copyWith(
        isScanning: false,
      ));
    }
  }

  Future<void> performOCR(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final TextRecognizer textRecognizer = TextRecognizer();

    try {
      updateIsScanning(true);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      String totalAmount = await processRecognizedText(recognizedText) ?? '';
      String month = await processRecognizedText(recognizedText) ?? '';

      emit(state.copyWith(totalAmount: totalAmount, month: month));

      updateIsScanning(false);
    } finally {
      textRecognizer.close();
    }
  }

  Future<PdfDocument> loadPdf({String? pdfPath, Uint8List? pdfBytes}) async {
    if ((kIsWeb && pdfBytes == null) || (!kIsWeb && pdfPath == null)) {
      throw ArgumentError("Debe proveerse 'pdfPath' o 'pdfBytes'.");
    }
    late final PdfDocumentRef docRef;
    late final pdfDocumentFromWeb;

    if (kIsWeb && pdfBytes!.isNotEmpty) {
      pdfDocumentFromWeb = (await PdfDocument.openData(pdfBytes));
    } else {
      docRef = PdfDocumentRefFile(
          pdfPath!); // Otras plataformas usan la ruta del archivo
    }

    PdfDocument document = kIsWeb
        ? await loadPdfDocument(null, pdfDocumentFromWeb)
        : await loadPdfDocument(docRef, null);
    return document;
  }

  Future<PdfDocument> loadPdfDocument(
      PdfDocumentRef? docRef, PdfDocument? documentFromWeb) async {
    late PdfDocument document;

    if (kIsWeb && documentFromWeb != null) {
      document = documentFromWeb;

      updateIsScanning(false);
    } else {
      document = await docRef!.loadDocument(
        (int pageNumber, [int? pageCount]) {
          // Progreso de la carga
          updateIsScanning(true);

          emit(
            state.copyWith(
                progressMessage: pageCount != null
                    ? "Cargando página $pageNumber de $pageCount..."
                    : "Cargando página $pageNumber..."),
          );
        },
        (totalPages, loadedPages, duration) {
          // Reporte final
          emit(state.copyWith(
              progressMessage:
                  "Cargado: $loadedPages / $totalPages páginas en $duration."));

          updateIsScanning(false);
        },
      );
    }
    return document;
  }

  bool isDaySelectedHoliday(DateTime currentTime) {
    // Obtener la lista de días festivos para el año actual
    final holidays = getHolidaysForCurrentYear(currentTime.year);
    return (currentTime.weekday == DateTime.sunday ||
        isHoliday(currentTime, holidays));
  }

  void updateIsFromPdf(bool isFromGallery) =>
      emit(state.copyWith(isFromPdf: isFromGallery));

  void initializeFlagsSource() {
    emit(state.copyWith(
        isFromPdf: false, isFromCamera: false, isScanning: false));
  }

  void extractCompanyInfo(String pdfText) {
    // Expresión regular para encontrar CIF
    final cifRegex = RegExp(r'\bCIF\s[A-Z]\d{8}\b', caseSensitive: false);

    // Expresión regular para encontrar nombres de empresas
    final nameRegex = RegExp(r'[A-Za-z\s.,ñÑáéíóúÁÉÍÓÚ\-]+s\.a\. unipersonal',
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
    } else {
      print('No se pudo encontrar información de la empresa.');
    }
  }

  void updatePathFile(File file) => emit(state.copyWith(file: file));

  void updatePageNumer(int page) => emit(
        state.copyWith(pageNumber: page),
      );

  void updateImageVisible(bool isImageVisible) => emit(
        state.copyWith(isImageVisible: isImageVisible),
      );

  Future<void> selectAndOpenPdf() async {
    try {
      if (kIsWeb) {
        await pickPdfFileForWeb();
        return;
      }
      // Seleccionar el archivo PDF
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        String? pdfPath = result.files.single.path;

        if (pdfPath != null) {
          updateIsScanning(true);
          updateIsFromPdf(true);
          updatePathFile(File(pdfPath));
          updateHasNavigate(false);

          // Procesar el archivo PDF
          final document = await loadPdf(pdfPath: pdfPath);

          // Buscar términos en el documento
          await searchQueryOnPdf(document); // Emitir estado de escaneo completo
        }
      } else {
        emit(state.copyWith(
            isError: "Selección de archivo cancelada",
            isLoading: false)); // Emitir error
      }
    } catch (e) {
      emit(state.copyWith(
          isError: "Error procesando el archivo: $e, ", isLoading: false));
    }
  }

  Future<void> searchQueryOnPdf(PdfDocument document) async {
    // Buscar términos en el documento
    await searchPdf(document, [
      "total importe a pagar",
      "Periodo de facturación",
      "nº factura",
      "Datos del contrato de electricidad",
      "Potencias contratadas",
      "CUPS",
      "Contrato de mercado libre:",
      "kwh evolucion del consumo",
      "INFORMACIÓN PARA EL CONSUMIDOR"
    ]);

    emit(
      state.copyWith(isLoading: false, hasNavigated: true, isComplete: true),
    ); // Emitir estado de escaneo completo
  }

  Future<void> launcLink(String url) async {
    final Uri url0 = Uri.parse(url);
    if (!await launchUrl(url0)) {
      throw Exception('Could not launch $url0');
    }
  }

  void updateHasNavigate(bool newValue) =>
      emit(state.copyWith(hasNavigated: newValue));

  void updateIsLoading(bool newValue) =>
      emit(state.copyWith(isLoading: newValue));

  void updateIsCompleted(bool newValue) =>
      emit(state.copyWith(isComplete: newValue));

  Future<void> pickPdfFileForWeb() async {
    // Crear un input de tipo file
    try {
      final html.FileUploadInputElement input = html.FileUploadInputElement();
      input.accept = ".pdf"; // Solo permite archivos PDF
      input.multiple = false; // No permite seleccionar múltiples archivos

      // Completer para manejar la respuesta de forma asíncrona
      final completer = Completer<Uint8List?>();

      // Escuchar el evento de selección de archivos
      input.onChange.listen((event) async {
        final List<html.File>? files = input.files;
        if (files != null && files.isNotEmpty) {
          final html.File file = files.first;

          // Usar FileReader para leer el contenido del archivo
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file);

          // Esperar a que termine la lectura
          await reader.onLoad.first;
          final Uint8List fileBytes = reader.result as Uint8List;

          // Completar con los bytes del archivo seleccionado
          completer.complete(fileBytes);
        } else {
          // Si el usuario cancela la selección
          completer.complete(null);
        }
      });

      // Simular el clic para abrir el diálogo de selección
      input.click();

      // Obtener los bytes del archivo seleccionado
      Uint8List? pdfBytes = await completer.future;

      if (pdfBytes != null) {
        print("Archivo PDF seleccionado con tamaño: ${pdfBytes.length} bytes");

        // Pasar los bytes del PDF al método loadPdf
        final PdfDocument document = await loadPdf(pdfBytes: pdfBytes);
        // Buscar términos en el documento
        await searchQueryOnPdf(document); // Emitir estado de escaneo completo
      } else {
        print("No se seleccionó ningún archivo.");
      }
    } on Exception catch (e) {
      print('Error $e');
    }
  }
}
