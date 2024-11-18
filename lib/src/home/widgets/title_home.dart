import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recibo_facil/const/colors_constants.dart';

class HomeTitle extends StatelessWidget {
  const HomeTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            'Lectura de facturas de energia',
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.raleway(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Transform.translate(
          offset: Offset(15, -16),
          child: IconButton(
            icon: Icon(Icons.more_vert, color: Colors.blueAccent, size: 28),
            onPressed: () => {},
          ),
        ),
      ],
    );
  }
}

class ReaderHomeTitle extends StatelessWidget {
  const ReaderHomeTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            'Leer factura',
            maxLines: 3,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.raleway(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            icon:
                Icon(Icons.more_vert, color: ColorsApp.baseColorApp, size: 28),
            onPressed: () => {},
          ),
        ),
      ],
    );
  }
}
