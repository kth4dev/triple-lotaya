import '../../values/sizes.dart';
import '../textstyles/textstyles.dart';
import 'package:flutter/material.dart';


class RemarkTextField extends StatelessWidget {
  final TextEditingController controller;

  const RemarkTextField({Key? key, required this.controller,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: formFieldsPaddingTopSize),
      child:   TextField(
        controller: controller,
        style: TextStyles.textFieldsTextStyle(context),
        maxLines: 10,
        minLines: 5,
        decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(3),
            ),
            hintText: 'Enter your reason'),
      ),
    );
  }
}