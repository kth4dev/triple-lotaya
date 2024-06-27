import 'package:flutter/material.dart';
import 'package:lotaya/core/extensions/size_extension.dart';
import 'package:lotaya/core/styles/styles.dart';
import 'package:lotaya/data/model/match.dart';
import 'package:lotaya/presentation/screens/sales/slip.dart';

import '../../../core/values/constants.dart';
import '../../../data/model/user.dart';
import '../../../domain/utils.dart';

class FindDigitWidget extends StatefulWidget {
  final List<Slip> slips;
  final DigitMatch selectedMatch;
  final TextEditingController controller;
  const FindDigitWidget({Key? key,required this.slips,required this.selectedMatch,required this.controller}) : super(key: key);

  @override
  State<FindDigitWidget> createState() => _FindDigitWidgetState();
}

class _FindDigitWidgetState extends State<FindDigitWidget> {

  @override
  Widget build(BuildContext context) {
    Map<String, int> winList = {};
    for (Account e in widget.selectedMatch.inAccounts) {
      if (e.type=="input") {
        winList.addAll({e.name:0});
      }
    }
    int sumTotal=0;
    int? winNumber=int.tryParse(widget.controller.text);
    if(winNumber!=null && winNumber>= 0 && winNumber<100){
      for(var s in widget.slips){
        for (var receipt in s.receipts) {
          for (var digit in receipt.digitList) {
            if (digit.value == widget.controller.text) {
              winList[s.userName]=winList[s.userName]!+digit.amount;
              sumTotal += digit.amount;
            }
          }
        }
      }
    }
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 500),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 400,
            child: Row(
              children: [
                Expanded(child: OutLinedTextField(controller: widget.controller, label: "Search", textInputType: TextInputType.number)),
                10.paddingWidth,
                DefaultButton(onPressed: (){
                  setState(() {});
                }, label: "Search")
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DefaultText("[Win Number : ${widget.controller.text}] Total = $sumTotal", style: TextStyles.bodyTextStyle.copyWith(color: Colors.teal)),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            color:  Colors.teal,
            child: Row(
              children: [
                DefaultText("အမည်", style: TextStyles.titleTextStyle.copyWith(color: Colors.white)),
                const Spacer(),
                DefaultText("ဒဲ့", style: TextStyles.titleTextStyle.copyWith(color: Colors.white)),
              ],
            ),
          ),
          ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: winList.length,
              itemBuilder: (context, index) {
                final name = winList.keys.elementAt(index);
                final amount = winList.values.elementAt(index);
                if(amount>0){
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4 , vertical: 8),
                    color: (index % 2 == 0) ? Color(0xfff6f4f4) : Colors.transparent,
                    child: Row(
                      children: [
                        DefaultText(name, style: TextStyles.titleTextStyle.copyWith(color: Colors.black)),
                        const Spacer(),
                        DefaultText(formatMoney(amount), style: TextStyles.titleTextStyle.copyWith(color: Colors.black)),
                      ],
                    ),
                  );
                }else{
                  return const SizedBox();
                }
              }),
          20.paddingHeight
        ],
      ),
    );
  }
}
