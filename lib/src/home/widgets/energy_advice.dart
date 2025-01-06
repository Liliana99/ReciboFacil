import 'package:flutter/material.dart';

class EnergyAdviceScreen extends StatelessWidget {
  const EnergyAdviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Caja de Consejo
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lightbulb,
                color: Colors.yellow,
                size: 30,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Consejo: Tu consumo es alto en enero. Intenta reducir la calefacción.",
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color.fromARGB(255, 245, 0, 0),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
