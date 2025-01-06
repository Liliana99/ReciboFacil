import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:recibo_facil/src/home/blocs/home_state_cubit.dart';
import 'package:recibo_facil/src/home/repositories/pdf_repository.dart';
import 'package:recibo_facil/src/home/utils/recognized_text.dart';

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
          plain: response.consumptionLlano ?? state.plain,
          valley: response.consumptionValle ?? state.valley,
          company: response.company ?? state.company,
          contract: response.contract ?? state.contract,
          cups: response.cups ?? state.cups));

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

  Future<PdfDocument> loadPdf(final String pdfPath) async {
    final docRef = PdfDocumentRefFile(pdfPath);
    PdfDocument document = await docRef.loadDocument(
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
    return document;
  }

  bool isDaySelectedHoliday(DateTime currentTime) {
    // Obtener la lista de días festivos para el año actual
    final holidays = getHolidaysForCurrentYear(currentTime.year);
    return (currentTime.weekday == DateTime.sunday ||
        isHoliday(currentTime, holidays));
  }

  void updateIsFromGallery(bool isFromGallery) =>
      emit(state.copyWith(isFromGallery: isFromGallery));

  void initializeFlagsSource() {
    emit(state.copyWith(
        isFromGallery: false, isFromCamera: false, isScanning: false));
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
}
