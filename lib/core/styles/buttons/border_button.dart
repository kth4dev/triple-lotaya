import '../textstyles/default_text.dart';
import '../textstyles/textstyles.dart';
import 'package:flutter/material.dart';

class BorderButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  const BorderButton({Key? key,required this.onPressed,required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style:ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(
                width: 1, // the thickness
                color: Colors.blue // the color of the border
            )
        ),
        onPressed: onPressed, child: DefaultText(label,style: TextStyles.buttonTextStyle.copyWith(color: Colors.blue),));
  }
}