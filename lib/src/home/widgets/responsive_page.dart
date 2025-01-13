import 'package:flutter/material.dart';
import 'package:recibo_facil/const/colors_constants.dart';

class ResponsiveHomePage extends StatelessWidget {
  const ResponsiveHomePage(
      {super.key,
      this.appBar,
      required this.body,
      this.floatingButton,
      this.floatingLocationButton,
      this.backgroundColor});
  final AppBar? appBar;
  final Widget? body;
  final Widget? floatingButton;
  final FloatingActionButtonLocation? floatingLocationButton;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    // Obtenemos las dimensiones de la pantalla con MediaQuery
    final Size size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    return Scaffold(
      backgroundColor: ColorsApp.baseColorApp,
      floatingActionButton: floatingButton,
      floatingActionButtonLocation: floatingLocationButton,
      body: SizedBox(
        height: screenHeight,
        // Ancho proporcional al 50% del tamaño del padre
        width: screenWidth > 600 ? screenWidth * 0.98 : double.infinity,
        child: body!,
      ),
    );
  }
}
