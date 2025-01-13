import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:recibo_facil/src/features/home/presentation/routes/app_router.dart';

class PdfViewerScreen extends StatelessWidget {
  final String pdfPath; // Ruta del archivo PDF (local o de red)

  const PdfViewerScreen({required this.pdfPath});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () => context.goNamed(Routes.detailBill),
              icon: Icon(
                Icons.arrow_back_ios,
                size: size.height * 0.03,
              )),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Center(
            child: PdfViewer.openFile(
              pdfPath, // Ruta al archivo PDF
              params: const PdfViewerParams(),
            ),
          ),
        ),
      ),
    );
  }
}
