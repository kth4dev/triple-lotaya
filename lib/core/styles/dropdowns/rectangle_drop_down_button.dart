import '../textstyles/default_text.dart';
import '../textstyles/textstyles.dart';
import 'package:flutter/material.dart';

class RectangleDropDownButton extends StatefulWidget {


  final List<String> values;
  final String selectedValue;
  final String label;
  final Function(String? value) onChange;
  const RectangleDropDownButton({Key? key,required this.values,required this.selectedValue,required this.label,required this.onChange}) : super(key: key);

  @override
  State<RectangleDropDownButton> createState() => _RectangleDropDownButtonState();
}

class _RectangleDropDownButtonState extends State<RectangleDropDownButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0),
      child: DropdownButtonFormField(
        decoration: InputDecoration(
          labelText: widget.label,
          border: const OutlineInputBorder(),
        ),
        value: (widget.selectedValue=="")? null:widget.selectedValue,
        hint: const DefaultText("Choose",style: TextStyles.dropDownButtonTextStyle,),
        items:  widget.values.map((label) => DropdownMenuItem<String>(value: label, child: DefaultText(label,style: TextStyles.dropDownButtonTextStyle,),)).toList(),
        onChanged: widget.onChange,
      ),
    );
  }
}