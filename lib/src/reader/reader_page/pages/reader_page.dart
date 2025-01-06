import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recibo_facil/src/home/pages/home_page/home_page.dart';
import 'package:recibo_facil/src/home/utils/custom_extension_sized.dart';
import 'package:recibo_facil/src/reader/reader_page/widgets/body_reader.dart';
import 'package:shimmer/shimmer.dart';

import '../../../services/service_locator.dart';
import '../../../home/blocs/home_cubit.dart';
import '../../../home/blocs/home_state_cubit.dart';

class ReaderPage extends StatelessWidget {
  const ReaderPage({super.key});

  void back(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => HomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(-1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isScanned = false;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocProvider(
        create: (context) => getIt<HomeCubit>(),
        child:
            BlocBuilder<HomeCubit, HomeStateCubit>(builder: (context, state) {
          if (state.isScanning!) {
            return Padding(
              padding: const EdgeInsets.only(
                  top: 24, bottom: 24, left: 24, right: 24),
              child: Column(
                children: [
                  SizedBox(
                    height: size.height * 0.50,
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[400]!,
                      highlightColor: Colors.grey[200]!,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(
                              50), // Bordes redondeados como el botón original
                        ),
                        alignment: Alignment.center, // Centrar el texto
                        child: SizedBox(
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[400]!,
                            highlightColor: Colors.grey[200]!,
                            child: Text(
                              'Cargando...',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  24.ht,
                  SizedBox(
                    height: size.height * 0.15,
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[400]!,
                      highlightColor: Colors.grey[200]!,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(
                              30), // Bordes redondeados como el botón original
                        ),
                        alignment: Alignment.center, // Centrar el texto
                        child: SizedBox(
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[400]!,
                            highlightColor: Colors.grey[200]!,
                            child: Text(
                              'Cargando...',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  12.ht,
                  SizedBox(
                    height: size.height * 0.15,
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[400]!,
                      highlightColor: Colors.grey[200]!,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(
                              30), // Bordes redondeados como el botón original
                        ),
                        alignment: Alignment.center, // Centrar el texto
                        child: SizedBox(
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[400]!,
                            highlightColor: Colors.grey[200]!,
                            child: Text(
                              'Cargando...',
                              style: TextStyle(
                                color: const Color.fromARGB(255, 8, 8, 8),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ReaderBody(size: size, back: () => back(context));
        }),
      ),
    );
  }
}

class CardChild extends StatelessWidget {
  const CardChild(
      {super.key,
      required this.size,
      required this.iconPath,
      required this.text,
      this.onPressed});
  final Size size;
  final String iconPath;
  final VoidCallback? onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: size.height * 0.035,
                child: Image.asset(
                  iconPath,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 7,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  width: size.width * 0.5,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: onPressed?.call,
                icon: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.black54,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
