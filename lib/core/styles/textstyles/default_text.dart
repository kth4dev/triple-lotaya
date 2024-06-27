import 'package:flutter/material.dart';

class DefaultText extends StatelessWidget {
  final String label;
  final TextStyle style;
  const DefaultText(this.label,{Key? key,required this.style}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(label, style: style,textScaleFactor: 1,);
  }
}
