import 'package:flutter/material.dart';
import 'package:recibo_facil/src/home/utils/custom_extension_sized.dart';

import 'package:shimmer/shimmer.dart';

class ShimmerReaderHomePage extends StatelessWidget {
  const ShimmerReaderHomePage({
    super.key,
    required this.isScanned,
    required this.size,
  });

  final bool isScanned;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.red,
      highlightColor: Colors.yellow,
      child: ListView(
        children: [
          100.ht,
          Container(
            height: size.height * 0.25,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(50)),
          ),
          20.ht,
          Container(
            height: size.height * 0.25,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(50)),
          ),
        ],
      ),
    );
  }
}

class ShimmerInitialReaderPage extends StatelessWidget {
  const ShimmerInitialReaderPage({
    super.key,
    required this.isScanned,
    required this.size,
  });

  final bool isScanned;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.red,
      highlightColor: Colors.yellow,
      child: ListView(
        children: [
          100.ht,
          Container(
            height: size.height * 0.25,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(50)),
          ),
          20.ht,
          Container(
            height: size.height * 0.25,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(50)),
          ),
        ],
      ),
    );
  }
}

class ShimmerHomePage extends StatelessWidget {
  final bool isScanned;

  const ShimmerHomePage({
    Key? key,
    required this.isScanned,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return ListView(
      children: [
        Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: size.height * 0.45,
                  width: size.width,
                  child: buildShimmerContainer(
                    isMainContainer: true,
                    size,
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height,
                  color: Colors.white,
                ),
              ],
            ),
            Positioned(
              top: size.height * 0.50 - 40,
              left: 16.0,
              right: 16.0,
              child: SizedBox(
                height: size.height * 0.18,
                child: buildShimmerContainer(
                  size,
                ),
              ),
            ),
            Positioned(
              top: size.height * 0.70 - 40,
              left: 16.0,
              right: 16.0,
              child: SizedBox(
                height: size.height * 0.18,
                child: buildShimmerContainer(
                  size,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildShimmerContainer(
    Size size, {
    final bool isMainContainer = false,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      enabled: true,
      child: Container(
        width: 200.0,
        height: 100.0,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: isMainContainer ? null : BorderRadius.circular(50),
        ),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[400]!, // Gris oscuro como base
          highlightColor: Colors.grey[200]!,
          child: Text(
            '',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 40.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
