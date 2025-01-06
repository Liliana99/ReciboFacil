import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:recibo_facil/src/home/blocs/utils/get_energy_advice.dart';
import 'package:recibo_facil/src/home/models/precios_api.dart';
import 'package:recibo_facil/src/reader/reader_page/pages/reader_page.dart';
import 'package:recibo_facil/src/home/repositories/prices_repository.dart';
import 'package:recibo_facil/src/home/utils/custom_extension_sized.dart';
import 'package:recibo_facil/src/home/utils/grafic.dart';
import 'package:recibo_facil/src/home/widgets/card_decoration.dart';
import 'package:recibo_facil/src/home/widgets/responsive_page.dart';

import 'package:recibo_facil/src/home/widgets/shimmer_home.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../const/colors_constants.dart';
import '../../blocs/home_cubit.dart';

class HomePage extends StatefulWidget {
  static const routeNameGrafic = '/home_page_grafic';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Timer timer;
  DateTime currentTime = DateTime.now();

  String _currentTime = '';

  final PreciosRepository _repository = PreciosRepository();
  late Future<PreciosAPI> _futurePrecios;

  late DateTime updatedTime;
  late final currentSegment;
  late final colors;

  late final segment;

  void _updateTime() {
    setState(() {
      _currentTime = _formatCurrentTime();
      updatedTime = DateTime.now();
    });
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        currentTime = DateTime.now();
        _updateTime(); // Actualiza cada segundo
      });
    });
    _futurePrecios = _repository.fetchPrecios();

    currentSegment = getCurrentSegment(DateTime.now());
    colors =
        segmentColors['${currentSegment["name"]}'] ?? segmentColors["default"]!;

    _updateTime(); // Inicializa la hora al cargar

    segment = getSegmentForCurrentTime(
      timeToTimeOfDay(updatedTime),
      segments,
    );
  }

  Future<void> _retryFetchingData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _futurePrecios = _repository.fetchPrecios();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void goToPage(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ReaderPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // Desde la derecha
          const end = Offset.zero; // A la posición actual
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
    final homeCubit = context.read<HomeCubit>();

    return ResponsiveHomePage(
      floatingButton: FutureBuilder<PreciosAPI>(
        future: _futurePrecios,
        builder: (context, snapshot) {
          // Verificar si está en estado de carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Mostrar shimmer en el FloatingActionButton
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                  height: size.height * 0.07,
                  width: size.width * 0.85,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
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
                  )),
            );
          } else {
            // Botón flotante interactivo
            return SizedBox(
              height: size.height * 0.07,
              width: size.width * 0.85,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FilledButton(
                  onPressed: () => goToPage(context),
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        ColorsApp.baseColorApp, // Color independiente del tema
                  ),
                  child: Text('Leer factura'),
                ),
              ),
            );
          }
        },
      ),
      floatingLocationButton: FloatingActionButtonLocation.centerDocked,
      body: FutureBuilder<PreciosAPI>(
          future: _futurePrecios,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ShimmerHomePage(
                isScanned: snapshot.connectionState == ConnectionState.waiting,
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error al cargar los datos: ${snapshot.error}'),
              );
            } else if (snapshot.hasData && snapshot.data != null) {
              final preciosAPI = snapshot.data!;

              final hitestHourprice = preciosAPI.resumenPrecios.precioMaximo;
              final lowestHourprice = preciosAPI.resumenPrecios.precioMinimo;

              final resultadoMasAlto =
                  obtenerPrecioMasAlto(preciosAPI.preciosPorHora);
              final resultadoMasBajo =
                  homeCubit.isDaySelectedHoliday(currentTime)
                      ? null
                      : obtenerPrecioMasBajo(preciosAPI.preciosPorHora);

              final currentSegmentTime = getCurrentSegment(currentTime);

              return ListView(
                children: [
                  Stack(
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            height: size.height * 0.45,
                            width: size.width,
                            child: CardContainer(
                                childText: EnergySegmentAdvice(
                                  currentTime: currentTime,
                                  generalColorStyle:
                                      colors["border"] == Colors.red
                                          ? Colors.white70
                                          : null,
                                  parenthesisStyle: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  updatedTime: updatedTime,
                                  peakWidgets:
                                      segment["widgets"] as List<Widget>,
                                ),
                                segmentTime: '${currentSegmentTime["name"]}'),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height,
                            color: ColorsApp.scaffoldBackgroundColor,
                          ),
                        ],
                      ),
                      Positioned(
                        top: 10,
                        right: size.width * 0.04,
                        child: Builder(builder: (context) {
                          final colors = segmentColors[currentSegmentTime] ??
                              segmentColors["default"]!;

                          return Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: colors["border"]!.withValues(
                                  alpha: 0.85), // Fondo con opacidad
                              shape: BoxShape.circle, // Forma redonda
                            ),
                            child: CircleAvatar(
                              backgroundColor:
                                  colors["border"]!.withValues(alpha: 0.5),
                              child: Icon(Icons.receipt_long_outlined,
                                  color: Colors.white54),
                            ),
                          );
                        }),
                      ),
                      if (resultadoMasBajo != null)
                        Positioned(
                          top: size.height * 0.45 - 40, // Adjust to overlap
                          left: 16.0,
                          right: 16.0,
                          child: SizedBox(
                            height: size.height * 0.18,
                            child: PageView.builder(
                              itemCount: 2,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: WhiteCardDecoration(
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: Column(
                                            children: [
                                              if (index == 0)
                                                Icon(
                                                  Icons.arrow_upward_outlined,
                                                  color: Colors.red,
                                                )
                                              else if (index == 1)
                                                Icon(
                                                  Icons.arrow_downward_outlined,
                                                  color: Colors.green,
                                                )
                                            ],
                                          ),
                                        ),
                                        0.07.wdRelative(size),
                                        Expanded(
                                          flex: 4,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (index == 0)
                                                Text(
                                                  'Precio más alto del dia \n${resultadoMasAlto['precio']}  €/kWh',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.red),
                                                  textAlign: TextAlign.left,
                                                  maxLines: 2,
                                                ),
                                              5.ht,
                                              if (index == 0)
                                                Text(
                                                  'Rango de horas : ${resultadoMasAlto['rango']} hras.',
                                                  textAlign: TextAlign.left,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.red),
                                                ),
                                              if (index == 1)
                                                Text(
                                                  'Precio más bajo del dia\n ${resultadoMasBajo['precio']}  €/kWh.',
                                                  textAlign: TextAlign.left,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.green),
                                                ),
                                              5.ht,
                                              if (index == 1)
                                                Text(
                                                  'Rango de horas : ${resultadoMasBajo['rango']} hras.',
                                                  textAlign: TextAlign.left,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.green),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      Positioned(
                        top: resultadoMasBajo != null
                            ? size.height * 0.62 - 10
                            : size.height * 0.40 - 10, // Adjust to overlap
                        left: 16.0, // Margin from the left
                        right: 16.0, // Margin from the right
                        child: WhiteCardDecoration(
                          child: ElectricityPriceWidget(
                              preciosPorHora: preciosAPI.preciosPorHora,
                              currentTime: currentTime),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            } else {
              _retryFetchingData();

              // Mostrar un mensaje si no hay datos
              return Center(child: Text('Buscando datos.'));
            }
          }),
    );
  }

  Color obtenerColorFranja(int hora) {
    if ((hora >= 10 && hora < 14) || (hora >= 18 && hora < 22)) {
      return Colors.red; // Hora Punta
    } else if ((hora >= 8 && hora < 10) ||
        (hora >= 14 && hora < 18) ||
        (hora >= 22 && hora < 24)) {
      return Colors.orange; // Hora Llano
    } else {
      return Colors.green; // Hora Valle
    }
  }
}

class WhiteCardDecoration extends StatelessWidget {
  const WhiteCardDecoration({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: child,
      ),
    );
  }
}

class ElectricityPriceWidget extends StatelessWidget {
  const ElectricityPriceWidget({
    super.key,
    required this.preciosPorHora,
    required this.currentTime,
  });

  final List<PrecioHora> preciosPorHora;
  final DateTime currentTime;

  @override
  Widget build(BuildContext context) {
    final horaActual = currentTime.hour;
    final minutes = currentTime.minute;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: CustomPaint(
            size: const Size(double.infinity, 90), // Tamaño del gráfico
            painter: PrecioLuzPainter(
              preciosPorHora: preciosPorHora,
              horaActual: horaActual,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Precio a las $horaActual:$minutes',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          '${currentTime.day}/${currentTime.month}/${currentTime.year}',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 10),
        Text(
          '${preciosPorHora[horaActual].precio.toStringAsFixed(4)} €/kWh',
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
        ),
      ],
    );
  }
}
