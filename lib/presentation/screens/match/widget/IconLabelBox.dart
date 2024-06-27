import 'package:flutter/material.dart';

import '../../../../core/styles/textstyles/default_text.dart';
import '../../../../core/styles/textstyles/textstyles.dart';

class IconLabelBox extends StatelessWidget {
  final String label;
  final IconData iconData;
  final Color color;
  const IconLabelBox({Key? key,required this.label,required this.iconData,required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: color)),
        child: Row(
          children: [
            Icon(
              iconData,
              size: 20,
              color: color,
            ),
            const SizedBox(
              width: 5,
            ),
            DefaultText(label,style: TextStyles.bodyTextStyle.copyWith(color:color),),
          ],
        ));
  }
}