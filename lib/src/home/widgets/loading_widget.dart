import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final double maxWidth;
  final double maxHeight;

  const Loading({
    super.key,
    required this.maxWidth,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedContainer(
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: const AlwaysStoppedAnimation<Color>(
                Color.fromARGB(255, 26, 121, 199)),
            backgroundColor: Colors.grey[200],
            strokeWidth: 5.0,
          ),
          const SizedBox(height: 16),
          Text(
            textAlign: TextAlign.left,
            maxLines: 2,
            'Analizando informacion de la factura...',
            style: TextStyle(color: Colors.blue),
          ),
        ],
      ),
    );
  }
}

class DecoratedContainer extends StatelessWidget {
  const DecoratedContainer(
      {super.key,
      required this.maxWidth,
      required this.maxHeight,
      required this.child});
  final double maxWidth;
  final double maxHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}
