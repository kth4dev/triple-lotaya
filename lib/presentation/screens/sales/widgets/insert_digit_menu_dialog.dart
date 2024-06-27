import 'package:flutter/material.dart';
import 'package:lotaya/core/styles/styles.dart';

class InsertDigitMenuDialog extends StatelessWidget {
  const InsertDigitMenuDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width*0.7,
      child: AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            children: [
               labelWithValue(key: "-", description: "နက္ခတ်"),
               const Divider(),
              labelWithValue(key: "*", description: "ပါဝါ"),
              const Divider(),
              labelWithValue(key: "**", description: "အပူး"),
              const Divider(),
              labelWithValue(key: "-+", description: "မစုံ"),
              const Divider(),
              labelWithValue(key: "+-", description: "စုံမ"),
              const Divider(),
              labelWithValue(key: "-", description: "ပတ်လည်"),
              const Divider(),
              labelWithValue(key: "ဂဏန်း*", description: "အပိတ်"),
              const Divider(),
              labelWithValue(key: "*ဂဏန်း", description: "ထိပ်စီး"),
              const Divider(),
              labelWithValue(key: "ဂဏန်း+", description: "R"),
              const Divider(),
              labelWithValue(key: "ဂဏန်း/", description: "ဘရိတ်"),
              const Divider(),
              DefaultButton(onPressed: ()=> Navigator.of(context).pop(), label: "Ok")
            ],
          ),
        ),
      ),
    );
  }

  Widget labelWithValue({required String key,required String description}){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DefaultText(key, style: TextStyles.titleTextStyle),
        DefaultText(description, style: TextStyles.bodyTextStyle)
      ],
    );
  }
}

void showInsertDigitMenuDialog({required BuildContext context}) {
  showDialog(
    context: context,
    builder: (context) => InsertDigitMenuDialog(),
  );
}

