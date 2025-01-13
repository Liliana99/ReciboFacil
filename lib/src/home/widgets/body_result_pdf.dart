import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:recibo_facil/const/assets_constants.dart';
import 'package:recibo_facil/const/colors_constants.dart';
import 'package:recibo_facil/src/features/home/presentation/blocs/home_cubit.dart';
import 'package:recibo_facil/src/features/home/presentation/blocs/home_state_cubit.dart';
import 'package:recibo_facil/src/home/utils/custom_extension_sized.dart';
import 'package:recibo_facil/src/home/widgets/button_rounded.dart';
import 'package:recibo_facil/src/home/widgets/extrac_image_from_pdf.dart';

class BodyResultPdf extends StatelessWidget {
  const BodyResultPdf({
    super.key,
    required this.size,
    required this.selectAndOpenPdf,
    required this.stateCubit,
  });
  final Size size;
  final HomeStateCubit stateCubit;
  final Future<void> Function(BuildContext, HomeCubit) selectAndOpenPdf;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              height: size.height * 0.50,
              width: size.width,
              color: ColorsApp.baseColorApp,
            ),
            Container(
              height: MediaQuery.of(context).size.height,
            ),
          ],
        ),
        Positioned(
          top: 10,
          right: size.width * 0.04,
          left: size.width * 0.06,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Recibo Fácil',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: ColorsApp.scaffoldBackgroundColor),
                  ),
                ),
                Expanded(
                  child: LottieBuilder.asset(Assets.billEnergyAnimation,
                      fit: BoxFit.contain),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: size.height * 0.20,
          right: size.width * 0.06,
          left: size.width * 0.06,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'A pagar  ',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: ColorsApp.scaffoldBackgroundColor),
              ),
            ),
          ),
        ),
        Positioned(
          top: size.height * 0.22,
          right: size.width * 0.06,
          left: size.width * 0.06,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${stateCubit.totalAmount} €',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Colors.white),
              ),
            ),
          ),
        ),
        Positioned(
          top: size.height * 0.37,
          left: size.width * 0.06,
          child: Row(
            spacing: 20,
            children: [
              Column(
                children: [
                  ButtonRounded(
                    iconPath: Assets.pdfIcon,
                    width: 45,
                    height: 45,
                    onPressed: () {},
                  ),
                  SizedBox(
                    width: 100,
                    child: Column(
                      children: [
                        Text(
                          'Ver recibo',
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: ColorsApp.whiteBaseColor,
                              fontWeight: FontWeight.w600),
                        ),
                        25.ht,
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  ButtonRounded(
                    icon: Icon(
                      Icons.bar_chart_outlined,
                      color: ColorsApp.whiteBaseColor,
                    ),
                    width: 45,
                    height: 45,
                    onPressed: () {},
                  ),
                  SizedBox(
                    width: 100,
                    child: Text(
                      'Comparar ofertas',
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: ColorsApp.whiteBaseColor,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (stateCubit.pageNumber != null && stateCubit.pageNumber! > 0)
          Positioned(
            top: size.height * 0.50,
            left: size.width * 0.05,
            child: !stateCubit.isImageVisible!
                ? SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: PdfOcrCropScreen(
                        pdfPath: stateCubit.file!.path,
                        pageNumber: stateCubit.pageNumber!,
                      ),
                    ),
                  )
                : Container(
                    height: MediaQuery.of(context).size.height *
                        0.75, // Limita la altura al 75% de la pantalla

                    decoration: BoxDecoration(
                      color: Colors.white, // Color de fondo de la tarjeta
                      borderRadius:
                          BorderRadius.circular(16.0), // Esquinas redondeadas
                      boxShadow: [
                        BoxShadow(
                          color: Colors
                              .black26, // Color de la sombra (ligeramente oscuro)
                          blurRadius: 8.0, // Difuminado de la sombra
                          offset: Offset(
                              0, 4), // Desplazamiento de la sombra (x, y)
                        ),
                      ],
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: PdfOcrCropScreen(
                        pdfPath: stateCubit.file!.path,
                        pageNumber: stateCubit.pageNumber!,
                      ),
                    ),
                  ),
          ),
      ],
    );
  }
}
