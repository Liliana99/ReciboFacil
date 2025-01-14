import 'package:flutter/material.dart';
import 'package:recibo_facil/src/features/home/presentation/utils/custom_extension_sized.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerHome extends StatelessWidget {
  const ShimmerHome({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: size.height * 0.05, horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Simula el leading
                Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),

                // Simula el trailing
                ShimmerMenu()
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: size.height * 0.5,
            child: ShimmerBottomSheetWidget(
              onPressedPDF: () async {},
              onPressedScanBill: () {},
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
              vertical: size.height * 0.15, horizontal: size.width * 0.05),
          child: SafeArea(
            child: ShimmerTitle(size: size),
          ),
        ),
      ],
    );
  }
}

class ShimmerBottomSheetWidget extends StatelessWidget {
  const ShimmerBottomSheetWidget({
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

    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
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
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Simula el leading
                            Container(
                              width: 40.0,
                              height: 40.0,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            // Simula el título y subtítulo
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 16.0,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 8.0),
                                  Container(
                                    width: 100.0,
                                    height: 14.0,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            // Simula el trailing
                            Container(
                              width: 20.0,
                              height: 20.0,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    30.ht,
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Simula el leading
                            Container(
                              width: 40.0,
                              height: 40.0,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            // Simula el título y subtítulo
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 16.0,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 8.0),
                                  Container(
                                    width: 100.0,
                                    height: 14.0,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            // Simula el trailing
                            Container(
                              width: 20.0,
                              height: 20.0,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
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

class ShimmerMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        mainAxisSize:
            MainAxisSize.min, // Asegura que el tamaño se ajuste al contenido
        crossAxisAlignment:
            CrossAxisAlignment.start, // Alineación a la izquierda
        children: [
          // Primera línea
          Container(
            width: 40.0, // Ancho de la línea
            height: 6.0, // Altura de la línea
            margin: const EdgeInsets.symmetric(
                vertical: 4.0), // Espaciado entre líneas
            color: Colors.white, // Color base para el shimmer
          ),
          // Segunda línea
          Container(
            width: 30.0, // Ancho ligeramente más corto
            height: 6.0,
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            color: Colors.white,
          ),
          // Tercera línea
          Container(
            width: 20.0, // Ancho más corto
            height: 6.0,
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

class ShimmerTitle extends StatelessWidget {
  const ShimmerTitle({super.key, required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: size.height * 0.01, horizontal: size.width * 0.005),
            child: SizedBox(
              width: double.infinity,
              height: 16,
              child: Container(
                width: double.infinity,
                height: 16.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(4.0), // Bordes redondeados
                ),
              ),
            ),
          ),
        ),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: size.height * 0.01, horizontal: size.width * 0.10),
            child: SizedBox(
              width: double.infinity,
              height: 16,
              child: Container(
                width: double.infinity,
                height: 16.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(4.0), // Bordes redondeados
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
