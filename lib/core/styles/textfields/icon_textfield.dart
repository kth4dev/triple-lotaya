
import 'package:flutter/material.dart';
import 'package:lotaya/core/extensions/size_extension.dart';

import '../../values/colors.dart';
import '../textstyles/textstyles.dart';

class IconTextField extends StatelessWidget {
  final IconData iconData;
  final TextEditingController controller;
  final String label;
  const IconTextField({Key? key,required this.iconData,required this.controller,required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: const Color(0xfff3f0f0), borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.all(5),
      child: Row(
        children: [
          10.paddingWidth,
          Icon(
            iconData,
            size: 24,
            color: Colors.green,
          ),
          10.paddingWidth,
          Expanded(child: TextField(
            style: TextStyles.textFieldsTextStyle(context),
            controller: controller,
            decoration: InputDecoration(border: InputBorder.none, hintText: label,),
          )),
        ],
      ),
    );
  }
}
