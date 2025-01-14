import 'package:flutter/material.dart';
import 'package:recibo_facil/const/assets_constants.dart';
import 'package:recibo_facil/src/features/home/presentation/utils/custom_extension_sized.dart';

class BottomSheetWidget extends StatelessWidget {
  const BottomSheetWidget({
    super.key,
    required this.onPressedPDF,
    required this.onPressedScanBill,
  });
  final VoidCallback onPressedPDF;
  final VoidCallback onPressedScanBill;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Expanded(
      flex: 2,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.03, vertical: screenHeight * 0.06),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    GestureDetector(
                      onTap: onPressedPDF,
                      child: ListTile(
                        leading: SizedBox(
                          height: 40,
                          child: Image.asset(
                            Assets.pdfIcon,
                            color: Colors.orange,
                          ),
                        ),
                        title: const Text("Subir factura desde archivo"),
                        subtitle: const Text("PDF"),
                        trailing: IconButton(
                          onPressed: null,
                          icon: const Icon(Icons.arrow_forward_ios_outlined),
                        ),
                      ),
                    ),
                    30.ht,
                    GestureDetector(
                      onTap: onPressedScanBill,
                      child: ListTile(
                        leading: SizedBox(
                          height: 40,
                          child: Image.asset(
                            Assets.camera,
                            color: Colors.orange,
                          ),
                        ),
                        title: const Text("Escanear factura"),
                        subtitle: const Text("Cámara"),
                        trailing: IconButton(
                          onPressed: null,
                          icon: const Icon(Icons.arrow_forward_ios_outlined),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
