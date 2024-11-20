import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:recibo_facil/src/home/blocs/home_state_cubit.dart';
import 'package:recibo_facil/src/home/repositories/pdf_repository.dart';

class HomeCubit extends Cubit<HomeStateCubit> {
  final PdfRepository _pdfRepository;
  HomeCubit(this._pdfRepository) : super(const HomeStateCubit());

  void updateScannedText(final String newValue) =>
      emit(state.copyWith(scannedText: newValue));

  void updateMonth(final String newValue) =>
      emit(state.copyWith(month: newValue));

  void updateTotalAmount(final String newValue) =>
      emit(state.copyWith(totalAmount: newValue));

  void updateIsScanning() =>
      emit(state.copyWith(isScanning: !state.isScanning!));

  Future<void> searchPdf(PdfDocument document, String query) async {
    emit(
      state.copyWith(isScanning: true),
    );

    try {
      // Ejecutar las búsquedas en paralelo

      final results = await Future.wait([
        _pdfRepository.searchTextOnPdf(document, 'a pagar'),
        _pdfRepository.searchTextOnPdf(document, 'Periodo de facturación'),
        _pdfRepository.searchTextOnPdf(document, 'Punta')
      ]);

      // Asignar los resultados
      final totalAmountResults = results[0];
      final monthResults = results[1];

      // Acumular los resultados
      final newState = state.copyWith(
        scannedText:
            '${totalAmountResults?.scannedText ?? ""}\n${monthResults?.scannedText ?? ""}',
        totalAmount: totalAmountResults?.totalAmount ?? state.totalAmount,
        month: monthResults?.month ?? state.month,
        isScanning: false,
      );

      // Emitir el estado final después de acumular todos los resultados
      if (newState != state) {
        emit(newState);
        print(
            'Nuevo estado emitido: ${newState.scannedText}, ${newState.totalAmount}, ${newState.month}');
      } else {
        print("El nuevo estado es igual al anterior, no se emite un cambio.");
      }
    } on Exception catch (e) {
      print('Error searching for PDF: $e');
      emit(state.copyWith(
          isScanning:
              false)); // Finalizar el estado de escaneo en caso de error
    }
  }
}
