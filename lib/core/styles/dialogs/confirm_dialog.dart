import '../../values/strings.dart';
import '../textstyles/default_text.dart';
import '../textstyles/textstyles.dart';
import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String title,content;
  final VoidCallback onPressedConfirm;
  const ConfirmDialog({Key? key,required this.title,required this.content,required this.onPressedConfirm}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: DefaultText(title, style: TextStyles.titleTextStyle,),
      content: DefaultText(content, style: TextStyles.bodyTextStyle,),
      actions: [
        TextButton(onPressed: ()=> Navigator.of(context).pop(),
            child: DefaultText(Strings.no,style: TextStyles.buttonTextStyle.copyWith(color: Colors.blue),)
        ),
        TextButton(onPressed: ()=> onPressedConfirm(),
            child: const DefaultText(Strings.yes,style: TextStyles.buttonTextStyle,)
        )
      ],
    );
  }
}

void showConfirmDialog({required BuildContext context,required  String title, required String content,required VoidCallback onPressedConfirm}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => ConfirmDialog(title: title, content: content, onPressedConfirm: onPressedConfirm),
  );
}
