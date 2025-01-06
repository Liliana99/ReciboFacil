import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recibo_facil/src/home/blocs/home_cubit.dart';
import 'package:recibo_facil/src/home/blocs/home_state_cubit.dart';
import 'package:recibo_facil/src/reader/reader_page/widgets/body_reader_initial.dart';
import 'package:recibo_facil/src/reader/reader_page/widgets/body_result_bill.dart';

class ReaderBody extends StatefulWidget {
  const ReaderBody({super.key, required this.size, required this.back});
  final Size size;
  final VoidCallback back;

  @override
  State<ReaderBody> createState() => _ReaderBodyState();
}

class _ReaderBodyState extends State<ReaderBody> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  Future<void> _selectFromGallery(HomeCubit homeCubit) async {
    homeCubit.updateIsFromGallery(true);
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
      await homeCubit.performOCR(_selectedImage!);
    }
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
          "contrato"
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
  void initState() {
    final homeCubitInitial = context.read<HomeCubit>();
    homeCubitInitial.initializeFlagsSource();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //final homeCubitInitial = context.read<HomeCubit>();
    Size size = MediaQuery.of(context).size;

    return BlocBuilder<HomeCubit, HomeStateCubit>(
      builder: (context, state) {
        if (state.scannedText != null && state.totalAmount != null) {
          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: SizedBox(
                height: size.height * 0.9,
                child: BodyResultBill(stateCubit: state)),
          );
        }

        return BodyReaderInitial(
          size: widget.size,
          back: widget.back,
          selectAndOpenPdf: (context, homeCubit) =>
              _selectAndOpenPdf(context, homeCubit),
          selectFromGallery: (HomeCubit homeCubit) =>
              _selectFromGallery(homeCubit),
        );
      },
    );
  }
}
