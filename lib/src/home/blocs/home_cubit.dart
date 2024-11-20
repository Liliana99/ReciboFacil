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
    emit(state.copyWith(isScanning: true));
    try {
      print('Entro en metodo en el cubit');
      final results = await _pdfRepository.searchTextOnPdf(document, query);
      if (results != null) {
        emit(state.copyWith(
            isScanning: false,
            scannedText: results.scannedText,
            month: results.month,
            totalAmount: results.totalAmount));
      }
    } on Exception catch (e) {
      print('Error searching for PDF: $e');
    }
  }
}
