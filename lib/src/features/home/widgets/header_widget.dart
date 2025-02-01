import 'package:flutter/material.dart';
import 'package:recibo_facil/const/colors_constants.dart';
import 'package:recibo_facil/src/features/home/presentation/utils/custom_extension_sized.dart';

import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'dart:io' if (dart.library.html) 'dart:html'
    as html; // ✅ Solo importa lo necesario

import 'package:recibo_facil/ui_theme_extension.dart';

class HeaderWidget extends StatelessWidget {
  final String title;
  final TextStyle? titleStyle;
  final String? subtitle;
  final Widget? leadingWidget; // Por ejemplo, un botón "Atrás"
  final List<Widget>? trailingWidgets; // Widgets adicionales
  final int? days;

  const HeaderWidget(
      {super.key,
      required this.title,
      this.titleStyle,
      this.subtitle,
      this.leadingWidget,
      this.trailingWidgets,
      this.days});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: (kIsWeb || defaultTargetPlatform == TargetPlatform.android)
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
  final int? days;

  const HeaderWidgetDetail(
      {super.key,
      required this.title,
      this.subtitle,
      this.trailingWidgets,
      required this.month,
      this.companyName,
      this.days}); // Widgets adicionales

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: (kIsWeb || defaultTargetPlatform == TargetPlatform.android)
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.10),
              child: SizedBox(
                width: 400,
                child: Text(
                  textAlign: TextAlign.center,
                  month,
                  style: context.bodyM!.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                ),
              ),
            ),
            if (days != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.10),
                child: SizedBox(
                  width: 400,
                  child: Text(
                    'dias ($days)',
                    textAlign: TextAlign.center,
                    style: context.bodyM!.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                  ),
                ),
              )
          ],
          0.07.htRelative(size),
          if (trailingWidgets != null && trailingWidgets!.isNotEmpty)
            Wrap(
              children: trailingWidgets!, // Widgets alineados a la derecha
            ),
        ],
      ),
    );
  }
}
