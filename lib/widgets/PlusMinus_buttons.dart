import 'package:flutter/material.dart';

class PlusMinusButtons extends StatelessWidget {
  const PlusMinusButtons({
    super.key,
    required this.onPressed,
    required this.icon,
  });
  final Function onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Color.fromARGB(255, 172, 172, 172),
      heroTag: null,
      onPressed: () {
        onPressed();
      },
      mini: true,
      child: Icon(icon),
    );
  }
}
