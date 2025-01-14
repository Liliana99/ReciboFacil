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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.hasNavigated = false});
  final bool hasNavigated;

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

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<HomeCubit, HomeStateCubit>(
        listener: (context, state) {
          print(
              'valores   state.isComplete!${state.isComplete!} && !state.isLoading! ${!state.isLoading!} && !state.hasNavigated! ${!state.hasNavigated!} && !widget.hasNavigated} ${!hasNavigated}');

          if (state.isComplete! && !state.hasNavigated! && !hasNavigated) {
            context.goNamed(
              Routes.detailBill,
              extra: {
                'hasNavigated': true,
                'homeCubit': context.read<HomeCubit>(),
              },
            );
          }
        },
        builder: (context, state) {
          return state.isLoading!
              ? ShimmerHome()
              : Stack(
                  children: [
                    Container(
                      color: ColorsApp.baseColorApp,
                    ),
                    SafeArea(
                      child: Column(
                        children: [
                          HeaderWidget(
                            title: "ReciboFácil",
                            subtitle:
                                "Sube tu factura de energía y analiza tu consumo.",
                            trailingWidgets: [],
                          ),
                          BottomSheetWidget(
                            onPressedPDF: () async {
                              final cubit = context.read<HomeCubit>();
                              cubit.updateIsLoading(true);
                              await cubit.selectAndOpenPdf();
                            },
                            onPressedScanBill: () {},
                          ),
                        ],
                      ),
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
  }
}
