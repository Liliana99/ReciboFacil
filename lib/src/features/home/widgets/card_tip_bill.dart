import 'package:flutter/material.dart';
import 'package:recibo_facil/const/colors_constants.dart';
import 'package:recibo_facil/src/features/home/presentation/utils/custom_extension_sized.dart';
import 'package:recibo_facil/src/features/home/presentation/utils/ui_helper.dart';
import 'package:recibo_facil/ui_theme_extension.dart';

class CardTipBill extends StatelessWidget {
  const CardTipBill(
      {super.key,
      required this.factura,
      required this.days,
      required this.size});
  final double factura;
  final int days;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final double umbral = 100;

    bool isBillExpensive = factura > umbral && days >= 29;

    Color backgroundColor = isBillExpensive
        ? Colors.yellow // Fondo amarillo si sobrepasa el umbral
        : Colors.white; // Fondo blanco si no lo sobrepasa

    // Mensaje mostrado según el valor de la factura
    String mensaje = isBillExpensive
        ? "Tu factura supera los $umbral euros en $days días.\n"
        : "Tu consumo está dentro de un rango aceptable.\n";
    String messageBaseTitle = "Consejos para ahorrar energía";
    String menssageBase = "1. Revisa los electrodomésticos.\n"
        "2. Desconecta dispositivos no utilizados.\n"
        "3. Ajusta la temperatura del aire acondicionado.\n"
        "4. Usa bombillas LED.";

    return Container(
      width: size.width * 0.03,
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey
                .withValues(alpha: 0.3), // Color gris con transparencia
            blurRadius: 5, // Desenfoque de la sombra
            spreadRadius: 1, // Extensión de la sombra
            offset: Offset(0, 2), // Desplazamiento de la sombra en x e y
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 10,
          children: [
            Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: size.width * 0.65,
                    child: Text(
                      mensaje,
                      maxLines: 2,
                      textAlign: TextAlign.left,
                      style: getResponsiveTextStyle(
                              context, context.bodyM!, context.bodyL!)
                          .copyWith(
                              color: isBillExpensive
                                  ? Colors.red
                                  : ColorsApp.baseColorApp,
                              fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Icon(Icons.lightbulb,
                      color: isBillExpensive ? Colors.red : Colors.yellow,
                      size: 24),
                ),
              ],
            ),
            10.ht,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  messageBaseTitle,
                  style: getResponsiveTextStyle(
                          context, context.bodyM!, context.bodyL!)
                      .copyWith(color: Colors.black),
                ),
              ],
            ),
            Text(
              menssageBase,
              style: getResponsiveTextStyle(
                      context, context.bodyM!, context.bodyL!)
                  .copyWith(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard2 extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final VoidCallback onPressed;
  const InfoCard2(
      {super.key,
      required this.child,
      required this.width,
      this.height,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
          width: width,
          height: height,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey
                    .withValues(alpha: 0.3), // Color gris con transparencia
                blurRadius: 5, // Desenfoque de la sombra
                spreadRadius: 1, // Extensión de la sombra
                offset: Offset(0, 2), // Desplazamiento de la sombra en x e y
              ),
            ],
          ),
          child: child),
    );
  }
}
