import '../../values/sizes.dart';
import '../textstyles/textstyles.dart';
import 'package:flutter/material.dart';


class PasswordTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const PasswordTextField({Key? key, required this.controller, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.only(top: formFieldsPaddingTopSize),
      child: TextField(
          style: TextStyles.textFieldsTextStyle(context),
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(border: const OutlineInputBorder(),hintText: label,labelText: label,)),
    );
  }
}