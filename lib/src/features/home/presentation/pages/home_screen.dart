import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:recibo_facil/const/colors_constants.dart';
import 'package:recibo_facil/src/core/navigation/routes/app_router.dart';
import 'package:recibo_facil/src/features/home/widgets/bottom_sheet_widget.dart';
import 'package:recibo_facil/src/features/home/widgets/header_widget.dart';
import 'package:recibo_facil/src/features/home/presentation/blocs/home_cubit.dart';
import 'package:recibo_facil/src/features/home/presentation/blocs/home_state_cubit.dart';
import 'package:recibo_facil/src/features/home/widgets/shimmer_home.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.hasNavigated = false});
  final bool hasNavigated;

  @override
  Widget build(BuildContext context) {
    bool showShimmer = true;
    const double minWidth = 500; // Bloquear anchos menores a 400px
    const double minHeight = 400;
    final size = MediaQuery.of(context).size;

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

    return LayoutBuilder(builder: (context, constraints) {
      bool isSmallScreen = constraints.maxWidth <= minWidth;

      print("constraints.maxWidth: ${constraints.maxWidth}");

      print("constraints.maxHeight: ${constraints.maxHeight}");

      return Scaffold(
        backgroundColor: Colors.white,
        body: BlocConsumer<HomeCubit, HomeStateCubit>(
          listener: (context, state) async {
            if (state.isComplete! && !state.hasNavigated! && !hasNavigated) {
              try {
                showShimmer = true;

                if (context.mounted) {
                  context.goNamed(
                    Routes.detailBill,
                    extra: {
                      'hasNavigated': true,
                      'homeCubit': context.read<HomeCubit>(),
                    },
                  );
                }
              } catch (error, stackTrace) {
                // Captura el error con Sentry
                await Sentry.captureException(
                  error,
                  stackTrace: stackTrace,
                );
                debugPrint('Error capturado: $error');
              }
            }
          },
          builder: (context, state) {
            return ((state.isLoading!) ||
                    (state.isComplete! && !state.isLoading!))
                ? ShimmerHome()
                : Stack(
                    children: [
                      Container(
                        color: ColorsApp.baseColorApp,
                      ),
                      SafeArea(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                              minWidth: minWidth, minHeight: minHeight),
                          child: isSmallScreen
                              ? Column(
                                  children: [
                                    HeaderWidget(
                                      title: "ReciboFácil",
                                      subtitle:
                                          "Sube tu factura de energía y analiza tu consumo.",
                                      trailingWidgets: [],
                                    ),
                                    BottomSheetWidget(
                                      size: size,
                                      onPressedPDF: () async {
                                        final cubit = context.read<HomeCubit>();
                                        cubit.updateIsLoading(true);
                                        await cubit.selectAndOpenPdf();
                                      },
                                      onPressedScanBill: () {},
                                      isSmallScreen: isSmallScreen,
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          HeaderWidget(
                                            title: "ReciboFácil",
                                            subtitle:
                                                "Sube tu factura de energía y analiza tu consumo.",
                                            trailingWidgets: [],
                                          ),
                                        ],
                                      ),
                                    ),
                                    BottomSheetWidget(
                                      size: size,
                                      onPressedPDF: () async {
                                        final cubit = context.read<HomeCubit>();
                                        cubit.updateIsLoading(true);
                                        await cubit.selectAndOpenPdf();
                                      },
                                      onPressedScanBill: () {},
                                      isSmallScreen: isSmallScreen,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      if (state.isLoading!)
                        AnimatedOpacity(
                          opacity: showShimmer ? 1.0 : 0.0,
                          duration: Duration(milliseconds: 300),
                          child: ShimmerHome(),
                        ),
                    ],
                  );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "I"),
            BottomNavigationBarItem(icon: Icon(Icons.payment), label: "P"),
            BottomNavigationBarItem(
                icon: Icon(Icons.currency_bitcoin), label: "C"),
            BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: "Más"),
          ],
        ),
      );
    });
  }
}
