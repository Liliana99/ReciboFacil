import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:recibo_facil/const/assets_constants.dart';
import 'package:recibo_facil/const/colors_constants.dart';
import 'package:recibo_facil/src/home/blocs/home_state_cubit.dart';
import 'package:recibo_facil/src/home/pages/home_page/home_page.dart';
import 'package:recibo_facil/src/home/utils/custom_extension_sized.dart';
import 'package:recibo_facil/src/reader/reader_page/widgets/container_decoration.dart';
import 'package:recibo_facil/src/reader/reader_page/widgets/pdf_carrusel.dart';
import 'package:flutter/material.dart';

class BodyResultBill extends StatefulWidget {
  const BodyResultBill({super.key, required this.stateCubit});
  final HomeStateCubit stateCubit;

  @override
  State<BodyResultBill> createState() => _BodyResultBillState();
}

class _BodyResultBillState extends State<BodyResultBill> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final TextStyle textStyle = TextStyle(
      fontSize: 12,
    );
    return FutureBuilder<ui.Image>(
      future: convertPdfPageToImage(
          widget.stateCubit.file!.path, 1), // Carga la primera página del PDF
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child:
                  CircularProgressIndicator()); // Muestra un indicador de carga
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar la imagen del PDF'));
        }

        return ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    onDoubleTap: () {
                      setState(() {});
                    },
                    child: InteractiveViewer(
                      child: RawImage(
                        image: snapshot.data!,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Positioned(
                      top: size.height * 0.25 - 50,
                      left: size.width * 0.005,
                      right: size.width * 0.005,
                      child: SizedBox(
                        height: size.height * 0.98,
                        child: DraggableScrollableSheet(
                            initialChildSize: 0.5,
                            minChildSize: 0.4,
                            maxChildSize: 0.98,
                            builder: (final BuildContext context,
                                final ScrollController scrollController) {
                              return RoundedTopContainer(
                                color:
                                    const ui.Color.fromARGB(197, 255, 255, 255),
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: size.width * 0.03,
                                      right: size.width * 0.03),
                                  child: ListView(
                                      controller: scrollController,
                                      children: [
                                        ModalDecorationLine(),
                                        10.ht,
                                        SizedBox(
                                          width: size.width * 0.80,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            spacing: 12,
                                            children: [
                                              Text(
                                                'A pagar : ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                '${widget.stateCubit.totalAmount} €',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                    color:
                                                        ColorsApp.baseColorApp),
                                              ),
                                            ],
                                          ),
                                        ),
                                        0.04.htRelative(size),
                                        SizedBox(
                                          child: Expanded(
                                            flex: 5,
                                            child: Row(
                                              spacing: 12,
                                              children: [
                                                Image.asset(
                                                  Assets.calender,
                                                  color: ColorsApp.baseColorApp,
                                                  width: 20,
                                                  height: 20,
                                                ),
                                                Text(
                                                  '${widget.stateCubit.month}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                  ),
                                                  maxLines: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: size.width * 0.80,
                                          child: Column(
                                            children: [
                                              0.02.htRelative(size),
                                              Text(
                                                'Potencia contratada',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                ),
                                                maxLines: 2,
                                              ),
                                              0.01.htRelative(size),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  spacing: 16,
                                                  children: [
                                                    Row(
                                                      spacing: 5,
                                                      children: [
                                                        Text(
                                                          'valle ',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 12,
                                                            color: ColorsApp
                                                                .baseColorApp,
                                                          ),
                                                        ),
                                                        Text(
                                                          '${widget.stateCubit.valley}',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 14,
                                                          ),
                                                          maxLines: 2,
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      spacing: 5,
                                                      children: [
                                                        Text(
                                                          'llano ',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 12,
                                                            color: ColorsApp
                                                                .baseColorApp,
                                                          ),
                                                        ),
                                                        Text(
                                                          '${widget.stateCubit.plain}',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 14,
                                                          ),
                                                          maxLines: 2,
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      spacing: 5,
                                                      children: [
                                                        Text(
                                                          'punta ',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 12,
                                                            color: ColorsApp
                                                                .baseColorApp,
                                                          ),
                                                        ),
                                                        Text(
                                                          '${widget.stateCubit.peak}',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 14,
                                                          ),
                                                          maxLines: 2,
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ]),
                                ),
                              );
                            }),
                      ))
                ],
              ),
            ),
            // Container(
            //   height: MediaQuery.of(context).size.height,
            //   color: Colors.white,
            // ),
          ],
        );
      },
    );
  }
}
