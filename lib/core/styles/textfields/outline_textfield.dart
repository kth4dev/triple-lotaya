import '../../values/sizes.dart';
import '../textstyles/textstyles.dart';
import 'package:flutter/material.dart';


class OutLinedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType textInputType;
  final bool? isValidation;

  const OutLinedTextField({Key? key, required this.controller, required this.label,required this.textInputType,this.isValidation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: formFieldsPaddingTopSize),
      child: TextFormField(
        validator: (value) {
          if(isValidation!=null && isValidation==true){
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
          }
          return null;
        },
        style: TextStyles.textFieldsTextStyle(context),
        textInputAction: TextInputAction.next,
        controller: controller,
        keyboardType: textInputType,
        decoration: InputDecoration(border: const OutlineInputBorder(), hintText: label,labelText: label),),
    );
  }
}