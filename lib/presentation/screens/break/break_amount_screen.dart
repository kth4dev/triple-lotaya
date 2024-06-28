import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lotaya/core/extensions/size_extension.dart';
import 'package:lotaya/core/styles/styles.dart';
import 'package:lotaya/presentation/widgets/empty_match.dart';

import '../../../data/collections.dart';
import '../../../data/model/match.dart';
import '../../bloc/matche/match_bloc.dart';

class BreakAmountScreen extends StatefulWidget {
  const BreakAmountScreen({Key? key}) : super(key: key);

  @override
  State<BreakAmountScreen> createState() => _BreakAmountScreenState();
}

class _BreakAmountScreenState extends State<BreakAmountScreen> {
  String _selectedMatchId="";
  late DigitMatch _selectedMatch;
  late TextEditingController breakAmountController;

  @override
  void initState() {
    super.initState();
    breakAmountController=TextEditingController();
    BlocProvider.of<MatchBloc>(context).add(GetAllMatch());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(context, title: "ကာစီး"),
      body:Padding(
        padding: (MediaQuery.of(context).size.width>600)?const EdgeInsets.all(10.0):const EdgeInsets.all(5),
        child: BlocBuilder<MatchBloc, MatchState>(
          builder: (context, state) {
            if(state is MatchLoadingState){
              return const Center(child: SizedBox(width:50,height:50,child: CircularProgressIndicator()));
            }
            if (state is MatchLoadedState) {
              List<String> matches=[];
              state.matchList.map((e) => matches.add("${e.date}")).toList();
              if(_selectedMatchId=="" && matches.isNotEmpty){
                _selectedMatchId=matches[0];
                _selectedMatch=state.matchList[0];

                for(int i=0;i<state.matchList.length;i++){
                  if(state.matchList[i].isActive){
                    _selectedMatchId = matches[i];
                    _selectedMatch = state.matchList[i];
                  }
                }
              }
              if(matches.isNotEmpty) {
                breakAmountController.text = _selectedMatch.breakAmount.toString();

                return Center(
                  child: SizedBox(
                    width: (MediaQuery.of(context).size.width >= 400) ? 400 : MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        10.paddingHeight,
                        Center(
                          child: UnderLineDropDownButton(
                            initialValue: _selectedMatchId,
                            values: matches,
                            label: "Match",
                            onChange: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedMatchId = newValue;
                                  _selectedMatch = state.matchList[matches.indexOf(newValue)];
                                });
                              }
                            },
                          ),
                        ),
                        10.paddingHeight,
                        OutLinedTextField(controller: breakAmountController, label: "Break Amount", textInputType: TextInputType.number),
                        10.paddingHeight,
                        PrimaryButton(onPressed: saveMatches, label: "Save")
                      ],
                    ),
                  ),
                );
              }else{
                return const EmptyMatchWidget();
              }
            }
            if(state is MatchErrorState){
              return  DefaultText(state.errorMessage, style: TextStyles.bodyTextStyle.copyWith(color: Colors.red));
            }
            return const DefaultText("Something went wrong", style: TextStyles.bodyTextStyle);
          },
        ),
      ),

    );
  }


  Future<void> saveMatches() async {
    int? newBreakAmount=int.tryParse(breakAmountController.text.toString());
    if(newBreakAmount!=null){
      if(newBreakAmount!=_selectedMatch.breakAmount){
        DigitMatch tempMatch=_selectedMatch;
        tempMatch.breakAmount=newBreakAmount;

        showLoadingDialog(context: context, title: "Change $_selectedMatchId 's Break Amount", content: "saving...");
        FirebaseFirestore.instance
            .collection(Collections.match)
            .doc(_selectedMatchId)
            .set(tempMatch.toJson())
            .then((value) {
          BlocProvider.of<MatchBloc>(context).add(GetAllMatch());
          Navigator.of(context).pop();
          Toasts.showSuccessToast("Save Successfully");
        }).catchError((error) {

          breakAmountController.text=_selectedMatch.breakAmount.toString();
          Navigator.of(context).pop();
          Toasts.showErrorMessageToast("Failed to change AM Match: $error");
        });
      }else{
        Toasts.showErrorMessageToast("Noting To Change");
      }

    }



  }

}
