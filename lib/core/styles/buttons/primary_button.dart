import '../../values/sizes.dart';
import '../textstyles/default_text.dart';
import '../textstyles/textstyles.dart';
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  const PrimaryButton({Key? key,required this.onPressed,required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: formFieldsPaddingTopSize),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(buttonHeight), // fromHeight use double.infinity as width and 40 is the height
          ),
          onPressed: onPressed, child: DefaultText(label,style: TextStyles.buttonTextStyle,)),
    );
  }
}

class DefaultButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  const DefaultButton({Key? key,required this.onPressed,required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: ElevatedButton(
          onPressed: onPressed, child: DefaultText(label,style: TextStyles.buttonTextStyle,)),
    );
  }
}



