import '../../values/strings.dart';
import '../textstyles/default_text.dart';
import '../textstyles/textstyles.dart';
import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  final String title, content;

  const LoadingDialog({Key? key, required this.title, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: DefaultText(title, style: TextStyles.titleTextStyle.copyWith(color: Colors.black, fontWeight: FontWeight.w500),),
        content: Row(
          children: [
            const CircularProgressIndicator(color: Colors.blue),
            const SizedBox(width: 20.0),
            DefaultText(content,style: TextStyles.bodyTextStyle.copyWith(color: Colors.black, fontWeight: FontWeight.w500),
            ),
          ],
        )
    );
  }
}

void showLoadingDialog({required BuildContext context,required String title,required String content}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => WillPopScope(
      child: LoadingDialog(title: title, content: content),
      onWillPop: () async {
        return false;
      },
    ),
  );
}
