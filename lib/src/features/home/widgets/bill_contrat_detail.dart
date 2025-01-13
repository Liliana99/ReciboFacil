import 'package:flutter/material.dart';
import 'package:recibo_facil/const/colors_constants.dart';
import 'package:recibo_facil/src/features/home/presentation/blocs/home_state_cubit.dart';
import 'package:recibo_facil/src/features/home/presentation/utils/ui_helper.dart';
import 'package:recibo_facil/src/home/utils/custom_extension_sized.dart';
import 'package:recibo_facil/ui_theme_extension.dart';

void openDraggableModal(BuildContext context, HomeStateCubit state) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Habilita el comportamiento "draggable"
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(16),
      ),
    ),
    builder: (BuildContext context) {
      final Size size = MediaQuery.of(context).size;

      return DraggableScrollableSheet(
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            padding: EdgeInsets.all(16),
            child: Column(
              spacing: 16,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Center(
                      child: ModalDecorationLine(
                        size: size,
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close,
                            size: size.height * 0.03,
                          )),
                    ),
                  ],
                ),
                Text(
                  'Detalles de tu contrato',
                  style: getResponsiveTextStyle(
                          context, context.bodyL!, context.dispM!)
                      .copyWith(
                          color: ColorsApp.baseColorApp,
                          fontWeight: FontWeight.bold),
                ),
                12.ht,
                Row(
                  spacing: 5,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Factura número:',
                      style: getResponsiveTextStyle(
                              context, context.bodyM!, context.bodyL!)
                          .copyWith(color: ColorsApp.baseColorApp),
                    ),
                    Text(
                      ' ${state.billNumber ?? ''}',
                      style: getResponsiveTextStyle(
                          context, context.bodyM!, context.bodyL!),
                    )
                  ],
                ),
                Row(
                  spacing: 5,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'CUPS:',
                      style: getResponsiveTextStyle(
                              context, context.bodyM!, context.bodyL!)
                          .copyWith(color: ColorsApp.baseColorApp),
                    ),
                    Text(
                      state.cups ?? '',
                      style: getResponsiveTextStyle(
                          context, context.bodyM!, context.bodyL!),
                    )
                  ],
                ),
                Row(
                  spacing: 5,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Contracto:',
                      style: getResponsiveTextStyle(
                              context, context.bodyM!, context.bodyL!)
                          .copyWith(color: ColorsApp.baseColorApp),
                    ),
                    Text(
                      state.contract ?? '',
                      style: getResponsiveTextStyle(
                          context, context.bodyM!, context.bodyL!),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class ModalDecorationLine extends StatelessWidget {
  const ModalDecorationLine({super.key, required this.size});
  final Size size;

  @override
  Widget build(final BuildContext context) {
    return Container(
      width: size.width * 0.25,
      height: 4,
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      decoration: BoxDecoration(
          color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
    );
  }
}
