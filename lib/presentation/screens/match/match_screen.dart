import 'package:flutter/material.dart';
import 'package:lotaya/core/extensions/size_extension.dart';
import 'package:lotaya/core/styles/appbars/appbar.dart';
import 'package:lotaya/presentation/screens/match/create_match_widget.dart';
import 'package:lotaya/presentation/screens/match/match_list_widget.dart';

import '../../../core/styles/textstyles/default_text.dart';
import '../../../core/styles/textstyles/textstyles.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({Key? key}) : super(key: key);

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(context, title: "ပွဲစဉ်ဇယား"),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: setUpUI(context),
          ),
        ],
      ),
    );
  }

  Widget setUpUI(BuildContext context){
    Widget createMatchWidget= CreateMatchWidget();
    Widget matchListWidget=MatchListScreen();
    double width=MediaQuery.of(context).size.width;
    if(width>1000){
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:  [
          Expanded(
              flex: 2,
              child:createMatchWidget),
          10.paddingWidth,
          Expanded(
              flex: 3,
              child: matchListWidget)
        ],
      );
    }else{
      return Column(
        children:  [
          ExpansionTile(
              initiallyExpanded: true,
              title:DefaultText("ပွဲအသစ်ဖန်တီးခြင်း", style: TextStyles.titleTextStyle.copyWith(fontWeight: FontWeight.bold)),
              children: [Padding(
                padding: const EdgeInsets.all(2.0),
                child: createMatchWidget,
              )]),
          10.paddingHeight,
          matchListWidget
        ],
      );
    }
  }

}
