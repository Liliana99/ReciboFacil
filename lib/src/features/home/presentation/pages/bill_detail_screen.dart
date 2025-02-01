import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recibo_facil/const/assets_constants.dart';
import 'package:recibo_facil/const/colors_constants.dart';
import 'package:recibo_facil/src/features/home/presentation/blocs/home_cubit.dart';
import 'package:recibo_facil/src/core/navigation/routes/app_router.dart';
import 'package:recibo_facil/src/features/home/presentation/utils/calculate_days_between.dart';
import 'package:recibo_facil/src/features/home/presentation/utils/custom_extension_sized.dart';
import 'package:recibo_facil/src/features/home/presentation/utils/parse_currency.dart';
import 'package:recibo_facil/src/features/home/presentation/utils/ui_helper.dart';
import 'package:recibo_facil/src/features/home/widgets/bill_contrat_detail.dart';
import 'package:recibo_facil/src/features/home/widgets/card_tip_bill.dart';
import 'package:recibo_facil/src/features/home/widgets/custom_icon_button.dart';
import 'package:recibo_facil/src/features/home/widgets/header_widget.dart';

import 'package:recibo_facil/ui_theme_extension.dart';

class BillDetailScreen extends StatelessWidget {
  const BillDetailScreen({
    super.key,
    required this.hasNavigated,
    required this.homeCubit,
  });

  final bool hasNavigated;
  final HomeCubit homeCubit;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    final currentState = homeCubit.state;

    final infoCard2Height = size.height * 0.20;

    print('height ${size.height}');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            context.goNamed(Routes.home, extra: false);

            Future.microtask(
              () {
                if (currentState.hasNavigated!) {
                  homeCubit.updateHasNavigate(false);
                  homeCubit.updateIsCompleted(false);
                }
              },
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(
              Icons.menu,
            ),
          )
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top Padding and Header
            SliverPadding(
              padding: const EdgeInsets.all(8.0),
              sliver: SliverToBoxAdapter(
                child: currentState.company == null
                    ? Center(child: Text('No hay datos'))
                    : HeaderWidgetDetail(
                        title: currentState.totalAmount ?? '',
                        subtitle: 'A pagar',
                        trailingWidgets: [
                          OptionsWidgets(
                            goToLink: currentState.qrcode != null
                                ? () => context
                                    .read<HomeCubit>()
                                    .launcLink(currentState.qrcode!)
                                : null,
                            openPDF: () => context.goNamed(Routes.pdfView),
                          ),
                        ],
                        companyName: currentState.company ?? '',
                        month: currentState.month ?? '',
                        days: currentState.startDate != null
                            ? calculateDaysBetween(
                                currentState.startDate!, currentState.endDate!)
                            : null,
                      ),
              ),
            ),

            // Main Content List
            if (currentState.company != null)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      if (index == 0) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.01,
                              horizontal: size.width * 0.03),
                          child: InfoCard2(
                            key: ValueKey('info_card_contract'),
                            width: size.width * 0.03,
                            height: infoCard2Height,
                            onPressed: () {
                              final state = context.read<HomeCubit>().state;
                              openDraggableModal(context, state);
                            },
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    Center(
                                      child: Text(
                                        'Datos del contrato',
                                        textAlign: TextAlign.center,
                                        style: context.bodyL!.copyWith(
                                          color: ColorsApp.baseColorApp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Icon(Icons.info_rounded),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.0),
                                Text(
                                  currentState.contract ?? '',
                                  style: context.bodyL!
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else if (index == 1 &&
                          currentState.totalAmount != null &&
                          currentState.startDate != null &&
                          currentState.endDate != null) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.01),
                          child: CardTipBill(
                            size: size,
                            key: ValueKey('info_card_tip_bill'),
                            days: calculateDaysBetween(
                                currentState.startDate!, currentState.endDate!),
                            factura: parseCurrency(currentState.totalAmount!),
                          ),
                        );
                      }

                      return null;
                    },
                    childCount: 2, // Number of items in the list
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class OptionsWidgets extends StatelessWidget {
  const OptionsWidgets({super.key, required this.goToLink, this.openPDF});
  final VoidCallback? goToLink;
  final VoidCallback? openPDF;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: MediaQuery.of(context).size.width *
          0.01, // 5% del ancho de la pantalla
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildOption(
            icon: Icon(Icons.open_with, color: Colors.white),
            text: 'Mejores ofertas',
            onPressed: () => goToLink?.call(),
            context: context),
        0.05.wdRelative(MediaQuery.of(context).size),
        _buildOption(
            icon: Image.asset(
              Assets.pdfIcon,
              color: Colors.white,
              fit: BoxFit.fill,
            ),
            text: 'Ver PDF',
            onPressed: () => openPDF?.call(),
            context: context),
        0.05.wdRelative(MediaQuery.of(context).size),
        _buildOption(
            icon: Icon(Icons.share, color: Colors.white),
            text: 'Compartir',
            onPressed: () {},
            context: context),
      ],
    );
  }
}

Widget _buildOption({
  required Widget icon,
  required String text,
  required VoidCallback? onPressed,
  required BuildContext context,
}) {
  return SizedBox(
    width: MediaQuery.of(context).size.width * 0.2,
    height: MediaQuery.of(context).size.height * 0.1,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomIconButton(
          icon: icon,
          onPressed: () => onPressed?.call(),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width *
              0.2, // Ancho fijo para evitar desbordes
          child: Text(
            text,
            style: getResponsiveTextStyle(
                context, context.labelS!, context.labelL!),
            maxLines: 3,
            textAlign: TextAlign.center, // Usa `center` para mejor alineación
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}
