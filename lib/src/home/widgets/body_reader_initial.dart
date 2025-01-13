import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recibo_facil/const/assets_constants.dart';
import 'package:recibo_facil/src/features/home/presentation/blocs/home_cubit.dart';
import 'package:recibo_facil/src/home/pages/home_page/home_page.dart';
import 'package:recibo_facil/src/reader/reader_page/pages/reader_page.dart';

class BodyReaderInitial extends StatelessWidget {
  const BodyReaderInitial({
    super.key,
    required this.size,
    required this.selectAndOpenPdf,
  });
  final Size size;

  final Future<void> Function(BuildContext, HomeCubit) selectAndOpenPdf;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 40,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 30,
          children: [
            InfoCard2(
              onPressed: () {},
              width: size.width,
              height: size.height * 0.100,
              child: CardChild(
                iconPath: 'assets/iconos/camera.png',
                text: 'Escanear recibo de la energia',
                size: size,
              ),
            ),
            InfoCard2(
              onPressed: () {
                final homeCubit = context.read<HomeCubit>();
                selectAndOpenPdf(context, homeCubit);
              },
              width: size.width,
              height: size.height * 0.100,
              child: CardChild(
                iconPath: Assets.pdfIcon,
                text: 'Seleccionar PDF',
                size: size,
                onPressed: () {
                  final homeCubit = context.read<HomeCubit>();
                  selectAndOpenPdf(context, homeCubit);
                },
              ),
            ),
          ],
        )
      ],
    );
  }
}
