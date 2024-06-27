import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lotaya/core/extensions/size_extension.dart';

import '../../core/styles/textstyles/default_text.dart';
import '../../core/styles/textstyles/textstyles.dart';

class EmptyMatchWidget extends StatelessWidget {
  const EmptyMatchWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.hourglass_empty),
        10.paddingHeight,
        const DefaultText("Empty Match",style: TextStyles.bodyTextStyle,),
      ],
    ),);
  }
}
