import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recibo_facil/const/assets_constants.dart';
import 'package:recibo_facil/const/colors_constants.dart';
import 'package:recibo_facil/src/home/utils/custom_extension_sized.dart';
import 'package:recibo_facil/ui_theme_extension.dart';

class ResponsiveScreenOld extends StatelessWidget {
  const ResponsiveScreenOld({super.key});

  @override
  Widget build(BuildContext context) {
    // Configurar la barra de estado para Android e iOS
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor:
            Colors.transparent, // Color de la barra de estado (Android)
        statusBarBrightness:
            Brightness.dark, // Texto claro en iOS (fondo oscuro en IOS)
        statusBarIconBrightness: Brightness.light, // Iconos claros en Android
      ),
    );

    // Obtener dimensiones de la pantalla
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Fondo azul (ocupa un 80% del alto de la pantalla)
          Container(
            height: screenHeight * 0.7,
            width: double.infinity,
            color: ColorsApp.baseColorApp,
          ),
          SafeArea(
            child: Column(
              children: [
                // Encabezado
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: Platform.isAndroid
                              ? MediaQuery.of(context).padding.top + 2.0
                              : 8.0, // Ajuste dinámico para Android
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.orange,
                              child: Text(
                                "M",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.menu, color: Colors.white),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        "ReciboFácil",
                        style: context.dispS!.copyWith(color: Colors.white),
                      ),
                      60.ht,
                      Text(
                        "Sube tu factura de energia, ReciboFácil analizará tu factura y te sugerirá consejos para mejorar tu consumo y tarifa ",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                    ],
                  ),
                ),
                // Contenedor blanco (con bordes redondeados)
                Spacer(),
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.06),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView(
                              children: [
                                ListTile(
                                  leading: SizedBox(
                                    height: 40,
                                    child: Image.asset(
                                      Assets.pdfIcon,
                                      color: Colors.orange,
                                    ),
                                  ),
                                  title: Text("Subir factura desde archivo"),
                                  subtitle: Text("PDF"),
                                  trailing:
                                      Icon(Icons.arrow_forward_ios_outlined),
                                ),
                                15.ht,
                                ListTile(
                                  leading: SizedBox(
                                    height: 40,
                                    child: Image.asset(
                                      Assets.camera,
                                      color: Colors.orange,
                                    ),
                                  ),
                                  title: Text("Escanear factura"),
                                  subtitle: Text("Camára"),
                                  trailing:
                                      Icon(Icons.arrow_forward_ios_outlined),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text("Ver todo"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: "Invertir"),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Pagos"),
          BottomNavigationBarItem(
              icon: Icon(Icons.currency_bitcoin), label: "Crypto"),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: "Más"),
        ],
      ),
    );
  }
}
