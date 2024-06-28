import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lotaya/core/extensions/size_extension.dart';
import 'package:lotaya/core/styles/appbars/appbar.dart';
import 'package:lotaya/core/styles/dialogs/confirm_dialog.dart';
import 'package:lotaya/presentation/widgets/empty_match.dart';

import '../../../core/styles/buttons/primary_button.dart';
import '../../../core/styles/dialogs/loading_dialog.dart';
import '../../../core/styles/dropdowns/under_line_drop_down_button.dart';
import '../../../core/styles/textfields/outline_textfield.dart';
import '../../../core/styles/textstyles/default_text.dart';
import '../../../core/styles/textstyles/textstyles.dart';
import '../../../core/styles/toasts/toasts.dart';
import '../../../data/collections.dart';
import '../../../data/model/match.dart';
import '../../bloc/matche/match_bloc.dart';

class HotNumberScreen extends StatefulWidget {
  const HotNumberScreen({Key? key}) : super(key: key);

  @override
  State<HotNumberScreen> createState() => _HotNumberScreenState();
}

class _HotNumberScreenState extends State<HotNumberScreen> {
  String _selectedMatchId = "";
  late DigitMatch _selectedMatch;
  late TextEditingController breakAmountController;

  @override
  void initState() {
    super.initState();
    breakAmountController = TextEditingController();
    BlocProvider.of<MatchBloc>(context).add(GetAllMatch());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(context, title: "ဟော့ဂဏန်း"),
      body: Padding(
        padding: (MediaQuery.of(context).size.width > 600) ? const EdgeInsets.all(10.0) : const EdgeInsets.all(5),
        child: BlocBuilder<MatchBloc, MatchState>(
          builder: (context, state) {
            if (state is MatchLoadingState) {
              return const Center(child: SizedBox(width: 50, height: 50, child: CircularProgressIndicator()));
            }
            if (state is MatchLoadedState) {
              List<String> matches = [];
              state.matchList.map((e) => matches.add(e.date)).toList();
              if (_selectedMatchId == "" && matches.isNotEmpty) {
                _selectedMatchId = matches[0];
                _selectedMatch = state.matchList[0];
                for(int i=0;i<state.matchList.length;i++){
                  if(state.matchList[i].isActive){
                    _selectedMatchId = matches[i];
                    _selectedMatch = state.matchList[i];
                  }
                }
              }

              if(matches.isNotEmpty){
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
                        OutLinedTextField(controller: breakAmountController, label: "Hot Number", textInputType: TextInputType.number),
                        10.paddingHeight,
                        PrimaryButton(onPressed: saveMatches, label: "Add"),
                        10.paddingHeight,
                        Card(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            width: double.infinity,
                            child: Column(
                              children: [
                                DefaultText("Hot Numbers", style: TextStyles.titleTextStyle.copyWith(color: Colors.black,fontWeight: FontWeight.bold)),
                                15.paddingHeight,
                                if (_selectedMatch.hotNumbers != null)
                                  Wrap(
                                    children: _selectedMatch.hotNumbers!
                                        .map((number) => Card(
                                      color: Colors.redAccent,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            DefaultText(
                                              "$number",
                                              style: TextStyles.titleTextStyle.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                                            ),
                                            IconButton(onPressed: (){
                                              showConfirmDialog(context: context, title: "Remove $number", content: "Are you sure you want to remove $number", onPressedConfirm: (){
                                                Navigator.of(context).pop();
                                                _selectedMatch.hotNumbers?.remove(number);
                                                showLoadingDialog(context: context, title: "Remove $number", content: "removing...");
                                                updateMatches();
                                              });
                                            }, icon: Icon(Icons.delete_forever_outlined,color: Colors.white,)),
                                          ],
                                        ),
                                      ),
                                    ))
                                        .toList(),
                                  ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }else{
                return const EmptyMatchWidget();
              }

            }
            if (state is MatchErrorState) {
              return DefaultText(state.errorMessage, style: TextStyles.bodyTextStyle.copyWith(color: Colors.red));
            }
            return const DefaultText("Something went wrong", style: TextStyles.bodyTextStyle);
          },
        ),
      ),
    );
  }

  Future<void> saveMatches() async {
    List digitList = breakAmountController.text.toString().split(".");
    List<int> newList = [];
    for (var value in digitList) {
      int? digit=int.tryParse(value);
      if(digit!=null){
        if (!newList.contains(digit) && digit < 100) {
          if (_selectedMatch.hotNumbers == null) {
            newList.add(digit);
          } else {
            if (!_selectedMatch.hotNumbers!.contains(digit)) {
              newList.add(digit);
            }
          }
        }
      }
    }

    if(newList.isNotEmpty) {
      showConfirmDialog(
        context: context,
        title: "Hot Number",
        content: newList.toString(),
        onPressedConfirm: () {
          Navigator.of(context).pop();
          if (_selectedMatch.hotNumbers == null) {
            _selectedMatch.hotNumbers = newList;
          } else {
            _selectedMatch.hotNumbers!.addAll(newList);
          }
          print(_selectedMatch.toJson().toString());
          showLoadingDialog(context: context, title: "Add Hot Numbers to $_selectedMatchId", content: "saving...");
          FirebaseFirestore.instance.collection(Collections.match).doc(_selectedMatchId).set(_selectedMatch.toJson()).then((value) {
            Navigator.of(context).pop();
            BlocProvider.of<MatchBloc>(context).add(GetAllMatch());
            Toasts.showSuccessToast("Save Successfully");
          }).catchError((error) {
            breakAmountController.text = _selectedMatch.breakAmount.toString();
            Navigator.of(context).pop();
            Toasts.showErrorMessageToast("Failed to Add Hot Nubmer: $error");
          });
        });
    }else{
      Toasts.showInfoToast("Nothing to add!");
    }
  }

  Future<void> updateMatches() async {
    FirebaseFirestore.instance.collection(Collections.match).doc(_selectedMatchId).set(_selectedMatch.toJson()).then((value) {
      Navigator.of(context).pop();
      BlocProvider.of<MatchBloc>(context).add(GetAllMatch());
      Toasts.showSuccessToast("Save Successfully");
    }).catchError((error) {
      breakAmountController.text = _selectedMatch.breakAmount.toString();
      Navigator.of(context).pop();
      Toasts.showErrorMessageToast("Failed to Add Hot Nubmer: $error");
    });
  }
}
