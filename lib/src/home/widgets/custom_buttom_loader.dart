import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final String iconPath;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;

  const CustomButton({
    required this.onPressed,
    required this.text,
    required this.iconPath,
    this.backgroundColor = const Color(0xFF81D4FA), // Default light blue
    this.iconColor = Colors.white,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Wrap(
          children: [
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                height: 50,
                width: 50,
                child: Image.asset(iconPath, color: iconColor),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
