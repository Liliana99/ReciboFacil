import 'package:flutter/material.dart';
import 'package:recibo_facil/src/home/utils/custom_extension_sized.dart';
import 'package:recibo_facil/src/home/widgets/shimmer.dart';

class ShimmerHomePage extends StatelessWidget {
  const ShimmerHomePage({
    super.key,
    required this.isScanned,
    required this.size,
  });

  final bool isScanned;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      linearGradient: shimmerGradient,
      child: ShimmerLoading(
        isLoading: isScanned,
        child: Column(
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
      ),
    );
  }
}
