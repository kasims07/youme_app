import 'package:flutter/material.dart';

import '../../colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPress;
  const CustomButton({Key? key, required this.text, required this.onPress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPress,
      child: Text(
        text,
        style: const TextStyle(color: blackColor),
      ),
      style: ElevatedButton.styleFrom(backgroundColor: tabColor, minimumSize: const Size(double.infinity, 50)),
    );
  }
}
