import 'package:flutter/material.dart';
import 'package:recibo_facil/const/colors_constants.dart';
import 'package:recibo_facil/src/home/utils/custom_extension_sized.dart';
import 'dart:io';
import 'package:recibo_facil/ui_theme_extension.dart';

class HeaderWidget extends StatelessWidget {
  final String title;
  final TextStyle? titleStyle;
  final String? subtitle;
  final Widget? leadingWidget; // Por ejemplo, un botón "Atrás"
  final List<Widget>? trailingWidgets; // Widgets adicionales

  const HeaderWidget({
    super.key,
    required this.title,
    this.titleStyle,
    this.subtitle,
    this.leadingWidget,
    this.trailingWidgets,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: Platform.isAndroid
                  ? MediaQuery.of(context).padding.top + 16.0
                  : 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                leadingWidget ??
                    CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: const Text(
                        "M",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                Row(
                  children: [const Icon(Icons.menu, color: Colors.white)],
                ),
              ],
            ),
          ),
          0.02.htRelative(size),
          Text(
            title,
            style: titleStyle ?? context.dispS!.copyWith(color: Colors.white),
          ),
          if (subtitle != null) ...[
            20.ht,
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: context.bodyL!.copyWith(color: Colors.white),
              ),
            ),
          ],
          // if (trailingWidgets != null && trailingWidgets!.isNotEmpty)
          0.05.htRelative(size),
          if (trailingWidgets != null && trailingWidgets!.isNotEmpty)
            SizedBox(
              width: size.width,
              child: Wrap(
                spacing:
                    size.width * 0.02, // Espaciado horizontal entre elementos
                runSpacing:
                    size.width * 0.01, // Espaciado vertical entre líneas
                children: trailingWidgets!, // Widgets alineados a la derecha
              ),
            ),
          0.07.htRelative(size),
        ],
      ),
    );
  }
}

class HeaderWidgetDetail extends StatelessWidget {
  final String title;
  final String month;
  final String? subtitle;
  final String? companyName;
  final List<Widget>? trailingWidgets;

  const HeaderWidgetDetail(
      {super.key,
      required this.title,
      this.subtitle,
      this.trailingWidgets,
      required this.month,
      this.companyName}); // Widgets adicionales

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: Platform.isAndroid
                  ? MediaQuery.of(context).padding.top + 16.0
                  : 8.0,
            ),
          ),
          0.02.htRelative(size),
          Align(
            alignment: Alignment.topLeft,
            child: Row(
              spacing: 12,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline:
                  TextBaseline.alphabetic, // Necesario para Baseline en Row

              children: [
                Baseline(
                  baseline: 30,
                  baselineType: TextBaseline.alphabetic,
                  child: Text(
                    title,
                    style: context.dispL!.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          if (subtitle != null) ...[
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                subtitle!,
                style: context.dispS!.copyWith(color: ColorsApp.baseColorApp),
              ),
            ),
            0.05.htRelative(size),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                companyName!,
                style: context.bodyL!.copyWith(
                    fontWeight: FontWeight.bold, color: ColorsApp.baseColorApp),
                maxLines: 2,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 400,
                child: Text(
                  month,
                  style: context.bodyM!.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                ),
              ),
            )
          ],
          0.05.htRelative(size),
          if (trailingWidgets != null && trailingWidgets!.isNotEmpty)
            Wrap(
              children: trailingWidgets!, // Widgets alineados a la derecha
            ),
        ],
      ),
    );
  }
}
