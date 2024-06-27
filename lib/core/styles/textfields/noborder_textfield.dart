import 'package:flutter/material.dart';

import '../textstyles/textstyles.dart';


class NoBorderTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const NoBorderTextField({Key? key, required this.controller,required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyles.textFieldsTextStyle(context),
      textInputAction: TextInputAction.search,
      controller: controller,
      decoration: InputDecoration(border: InputBorder.none, hintText: label),
      );
  }
}