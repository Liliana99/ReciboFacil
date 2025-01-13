import 'package:flutter/material.dart';
import 'package:recibo_facil/const/colors_constants.dart';
import 'package:recibo_facil/src/features/home/presentation/utils/ui_helper.dart';
import 'package:recibo_facil/ui_theme_extension.dart';

class CardTipBill extends StatelessWidget {
  const CardTipBill({super.key, required this.factura});
  final double factura;

  @override
  Widget build(BuildContext context) {
    final double umbral = 100.0;
    final int dias = 30;

    Color backgroundColor = (factura > umbral && dias <= 30)
        ? Colors.yellow // Fondo amarillo si sobrepasa el umbral
        : Colors.white; // Fondo blanco si no lo sobrepasa

    bool isBillExpensive = factura > umbral && dias <= 30;
    // Mensaje mostrado según el valor de la factura
    String mensaje = isBillExpensive
        ? "Tu factura supera los $umbral euros en $dias días.\n"
        : "Tu consumo está dentro de un rango aceptable.\n";
    String messageBaseTitle = "Consejos para ahorrar energía";
    String menssageBase = "1. Revisa los electrodomésticos.\n"
        "2. Desconecta dispositivos no utilizados.\n"
        "3. Ajusta la temperatura del aire acondicionado.\n"
        "4. Usa bombillas LED.";

    return Card(
      color: backgroundColor,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 10,
          children: [
            Text(
              mensaje,
              style: getResponsiveTextStyle(
                      context, context.bodyM!, context.bodyL!)
                  .copyWith(
                      color: isBillExpensive
                          ? Colors.red
                          : ColorsApp.baseColorApp),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  messageBaseTitle,
                  style: getResponsiveTextStyle(
                          context, context.bodyM!, context.bodyL!)
                      .copyWith(color: Colors.black),
                ),
                Icon(Icons.lightbulb, color: Colors.yellow, size: 24),
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
