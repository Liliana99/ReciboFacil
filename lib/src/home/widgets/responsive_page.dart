import 'package:flutter/material.dart';

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

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 232, 234, 245),
        appBar: appBar,
        floatingActionButton: floatingButton,
        floatingActionButtonLocation: floatingLocationButton,
        body: Center(
          child: FractionallySizedBox(
            // Ancho proporcional al 50% del tamaño del padre
            widthFactor: screenWidth > 600
                ? 0.98
                : 1, // 40% en pantallas grandes, 80% en pequeñas
            heightFactor: screenHeight > 800 ? 1 : 0.80,
            child: body!,
          ),
        ),
      ),
    );
  }
}
