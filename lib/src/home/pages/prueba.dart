import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:recibo_facil/src/home/blocs/home_cubit.dart';
import 'package:recibo_facil/src/home/blocs/home_state_cubit.dart';
import 'package:recibo_facil/src/home/utils/custom_extension_sized.dart';
import 'package:recibo_facil/src/services/service_locator.dart';

class Prueba extends StatelessWidget {
  const Prueba({super.key});

  Future<PdfDocument?> _loadPdf(final String pdfPath) async {
    final docRef = await PdfDocumentRefFile(pdfPath);
    File? _selectedImage;
    late PdfDocument document;

    document = await docRef.loadDocument(
      (int pageNumber, [int? pageCount]) {
        // Progreso de la carga
      },
      (totalPages, loadedPages, duration) {
        // Reporte final
      },
    );
    print("PDF cargado con ${document.pages.length} páginas.");
    return document;
  }

  Future<void> selectAndOpenPdf(
      BuildContext context, HomeCubit homeCubit) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      String? pdfPath = result.files.single.path;
      String query = "a pagar";
      homeCubit.updateIsScanning();

      if (pdfPath != null) {
        var documentResult = await _loadPdf(pdfPath);
        for (int i = 0; i < 2; i++) {
          if (i == 1) {
            query = "Periodo de facturación";
          }

          await homeCubit.searchPdf(documentResult!, query);
        }
      }
    } else {
      // Usuario canceló la selección
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selección de archivo cancelada')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeCubit = getIt<HomeCubit>();

    return BlocProvider(
      create: (context) => getIt<HomeCubit>(),
      child: BlocBuilder<HomeCubit, HomeStateCubit>(
        builder: (context, state) {
          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.month ?? 'No hay datos del Mes'),
                  50.ht,
                  Text(state.totalAmount ?? 'No hay datos del valor'),
                  30.ht,
                  ElevatedButton(
                      onPressed: () async {
                        final homeCubit = context.read<HomeCubit>();
                        await selectAndOpenPdf(context, homeCubit);
                      },
                      child: Text('Leer PDF'))
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
