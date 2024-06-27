import 'package:flutter/material.dart';

class CloseIconButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CloseIconButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.white),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
        child: const Icon(Icons.close,color: Colors.black,));
  }
}
