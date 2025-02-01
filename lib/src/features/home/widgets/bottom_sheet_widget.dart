import 'package:flutter/material.dart';
import 'package:recibo_facil/const/assets_constants.dart';
import 'package:recibo_facil/src/features/home/presentation/utils/custom_extension_sized.dart';

class BottomSheetWidget extends StatelessWidget {
  const BottomSheetWidget({
    super.key,
    required this.onPressedPDF,
    required this.onPressedScanBill,
    required this.size,
    required this.isSmallScreen,
  });
  final VoidCallback onPressedPDF;
  final VoidCallback onPressedScanBill;
  final Size size;
  final bool isSmallScreen;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Expanded(
      flex: 2,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: isSmallScreen
              ? BorderRadius.vertical(
                  top: Radius.circular(30),
                )
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.03, vertical: screenHeight * 0.06),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: ListView(
                  shrinkWrap:
                      false, // ✅ Evita que ListView crezca indefinidamente
                  children: [
                    if (!isSmallScreen) 0.20.htRelative(size),
                    Center(
                      child: GestureDetector(
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
                    ),
                    if (!isSmallScreen) 0.20.htRelative(size),
                    if (isSmallScreen) 0.10.htRelative(size),
                    Center(
                      child: GestureDetector(
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
