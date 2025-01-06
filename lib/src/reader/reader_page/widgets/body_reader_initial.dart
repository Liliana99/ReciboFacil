import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recibo_facil/src/home/blocs/home_cubit.dart';
import 'package:recibo_facil/src/home/pages/home_page_reader.dart';
import 'package:recibo_facil/src/home/utils/custom_extension_sized.dart';
import 'package:recibo_facil/src/reader/reader_page/pages/reader_page.dart';

class BodyReaderInitial extends StatefulWidget {
  const BodyReaderInitial(
      {super.key,
      required this.size,
      required this.back,
      required this.selectAndOpenPdf,
      required this.selectFromGallery});
  final Size size;
  final VoidCallback back;
  final Future<void> Function(BuildContext, HomeCubit) selectAndOpenPdf;
  final Future<void> Function(HomeCubit homeCubit) selectFromGallery;

  @override
  State<BodyReaderInitial> createState() => _BodyReaderInitialState();
}

class _BodyReaderInitialState extends State<BodyReaderInitial> {
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 30,
      children: [
        Row(
          children: [
            Flexible(
              child: Transform.translate(
                offset: Offset(-20, -widget.size.height * 0.06),
                child: IconButton(
                  onPressed: () => widget.back(),
                  icon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: SizedBox(
                height: widget.size.height * 0.2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Seleccione el metodo para cargar su factura de la energia',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
        20.ht,
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 30,
          children: [
            InfoCard2(
              onPressed: () {},
              width: widget.size.width,
              height: widget.size.height * 0.090,
              child: CardChild(
                iconPath: 'assets/iconos/camera.png',
                text: 'Escanear recibo de la energia',
                size: widget.size,
              ),
            ),
            InfoCard2(
              onPressed: () {
                final homeCubit = context.read<HomeCubit>();
                widget.selectAndOpenPdf(context, homeCubit);
              },
              width: widget.size.width,
              height: widget.size.height * 0.090,
              child: CardChild(
                iconPath: 'assets/iconos/pdf.png',
                text: 'Seleccionar PDF',
                size: widget.size,
                onPressed: () {
                  final homeCubit = context.read<HomeCubit>();
                  widget.selectAndOpenPdf(context, homeCubit);
                },
              ),
            ),
          ],
        )
      ],
    );
  }
}
