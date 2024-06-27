
import 'package:flutter/material.dart';


class UnderLineDropDownButton extends StatefulWidget {
  final List<String> values;
  final String initialValue;
  final String label;
  final Function(String? value) onChange;
  const UnderLineDropDownButton({Key? key,required this.values,required this.initialValue,required this.label,required this.onChange}) : super(key: key);

  @override
  State<UnderLineDropDownButton> createState() => _UnderLineDropDownButtonState();
}

class _UnderLineDropDownButtonState extends State<UnderLineDropDownButton> {

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      isExpanded: true,
      decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: widget.label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10,vertical: 0)
      ),
      value: (widget.initialValue=="")? null:widget.initialValue,
      hint: Text("Choose"),
      items:  widget.values
          .map((e) => DropdownMenuItem<String>(
        value: e,
        child: Text(e),
      )).toList(),
      onChanged: widget.onChange,
    );
  }
}