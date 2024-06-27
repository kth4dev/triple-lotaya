import '../../values/strings.dart';
import '../textstyles/default_text.dart';
import '../textstyles/textstyles.dart';
import 'package:flutter/material.dart';

class InfoDialog extends StatelessWidget {
  final String title,content;
  const InfoDialog({Key? key,required this.title,required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: DefaultText(title, style: TextStyles.titleTextStyle,),
        content: DefaultText(content, style: TextStyles.bodyTextStyle,),
        actions: [
          TextButton(onPressed: ()=> Navigator.of(context).pop(),
              child: const DefaultText(Strings.ok,style: TextStyles.buttonTextStyle,)
          )
        ],
    );
  }
}


void showInfoDialog({required BuildContext context,required  String title, required String content}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => InfoDialog(title: title, content: content),
  );
}
