import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lotaya/core/extensions/size_extension.dart';
import 'package:lotaya/core/values/constants.dart';
import 'package:lotaya/data/model/win_amount.dart';
import 'package:lotaya/presentation/bloc/win_number/win__number_bloc.dart';
import 'package:lotaya/presentation/widgets/empty_match.dart';

import '../../../core/styles/appbars/appbar.dart';
import '../../../core/styles/buttons/primary_button.dart';
import '../../../core/styles/dialogs/loading_dialog.dart';
import '../../../core/styles/dropdowns/under_line_drop_down_button.dart';
import '../../../core/styles/textfields/outline_textfield.dart';
import '../../../core/styles/textstyles/default_text.dart';
import '../../../core/styles/textstyles/textstyles.dart';
import '../../../core/styles/toasts/toasts.dart';
import '../../../data/collections.dart';
import '../../../data/model/match.dart';
import '../../../data/model/user.dart';
import '../../bloc/matche/match_bloc.dart';

class WinNumberScreen extends StatefulWidget {
  const WinNumberScreen({Key? key}) : super(key: key);

  @override
  State<WinNumberScreen> createState() => _WinNumberScreenState();
}

class _WinNumberScreenState extends State<WinNumberScreen> {
  String _selectedMatchId = "";
  String _selectedType = "in";
  late DigitMatch _selectedMatch;
  late TextEditingController winNumberController;

  @override
  void initState() {
    super.initState();
    winNumberController = TextEditingController();
    BlocProvider.of<MatchBloc>(context).add(GetAllMatch());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(context, title: "ပေါက်သီး"),
      body: Padding( 
        padding: (MediaQuery.of(context).size.width > 600)
            ? const EdgeInsets.all(10.0)
            : const EdgeInsets.all(5),
        child: BlocBuilder<MatchBloc, MatchState>(
          builder: (context, state) {
            if (state is MatchLoadingState) {
              return const Center(
                  child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator()));
            }
            if (state is MatchLoadedState) {
              List<String> matches = [];
              state.matchList.map((e) => matches.add("${e.date}")).toList();
              if (_selectedMatchId == "" && matches.isNotEmpty) {
                _selectedMatchId = matches[0];
                _selectedMatch = state.matchList[0];
      
                for (int i = 0; i < state.matchList.length; i++) {
                  if (state.matchList[i].isActive) {
                    _selectedMatchId = matches[i];
                    _selectedMatch = state.matchList[i];
                  }
                }
              }
      
              if (matches.isNotEmpty) {
                if (_selectedMatch.winnerNumber != null) {
                  winNumberController.text =
                      _selectedMatch.winnerNumber.toString();
                  getLoadData();
                } else {
                  winNumberController.text = "";
                }
      
                return Center(
                  child: SizedBox(
                    width: (MediaQuery.of(context).size.width >= 600)
                        ? 600
                        : MediaQuery.of(context).size.width,
                    child: ListView(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: UnderLineDropDownButton(
                                initialValue: _selectedMatchId,
                                values: matches,
                                label: "Match",
                                onChange: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedMatchId = newValue;
                                      _selectedMatch = state
                                          .matchList[matches.indexOf(newValue)];
                                      if (_selectedMatch.winnerNumber != null) {
                                        getLoadData();
                                      }
                                    });
                                  }
                                },
                              ),
                            ),
                            10.paddingWidth,
                            SizedBox(
                              width: 100,
                              child: UnderLineDropDownButton(
                                initialValue: _selectedType,
                                values: const ["in", "out"],
                                label: "Type",
                                onChange: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedType = newValue;
                                      if (_selectedMatch.winnerNumber != null) {
                                        getLoadData();
                                      }
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        5.paddingHeight,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                                child: OutLinedTextField(
                                    controller: winNumberController,
                                    label: "Win Number",
                                    textInputType: TextInputType.number)),
                            10.paddingWidth,
                            SizedBox(
                                width: 100,
                                height: 40,
                                child: DefaultButton(
                                    onPressed: saveMatches, label: "သိမ်းမည်"))
                          ],
                        ),
                        if (_selectedMatch.winnerNumber == null)
                          const Padding(
                            padding: EdgeInsets.only(top: 18.0),
                            child: DefaultText("ပေါက်သီး မရှိပါ",
                                style: TextStyles.bodyTextStyle),
                          ),
                        if (_selectedMatch.winnerNumber != null)
                          userAndWinAmount((_selectedType == "in")
                              ? _selectedMatch.inAccounts
                              : _selectedMatch.outAccounts)
                      ],
                    ),
                  ),
                );
              } else {
                return const EmptyMatchWidget();
              }
            }
            if (state is MatchErrorState) {
              return DefaultText(state.errorMessage,
                  style: TextStyles.bodyTextStyle.copyWith(color: Colors.red));
            }
            return const DefaultText("Something went wrong",
                style: TextStyles.bodyTextStyle);
          },
        ),
      ),
    );
  }

  Widget userAndWinAmount(List<Account> accounts) {
    return Expanded(
      child: BlocBuilder<WinNumberBloc, WinNumberState>(
        builder: (context, state) {
          if (state is WinNumberLoadedState) {
            List<DataRow> list = [];
            for(var win in state.winList.entries){
              final data = win.value;
              list.add(DataRow(cells: [
                buildRow(value: win.key),
                buildRow(value: formatMoney(data.win)),
                buildRow(value: formatMoneyForNum(data.twit))
              ]));
            }

            list.add(DataRow(color: MaterialStateColor.resolveWith((states) => const Color(0xfff5f3f3)), cells: [
              buildRow(value: "Total"),
              buildRow(value: formatMoney(state.winTotal)),
              buildRow(value: formatMoney(state.twitTotal)),
            ]));
            return DataTable(
                headingRowColor: MaterialStateColor.resolveWith((states) => const Color(0xfff5f3f3)),
                columns: [
                  buildRowHeader("အမည်"),
                  buildRowHeader("ဒဲ့"),
                  buildRowHeader("တွဒ်"),
                ],
                rows: list);
          }
          if (state is WinNumberLoadingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return const DefaultText("Something went wrongs",
              style: TextStyles.bodyTextStyle);
        },
      ),
    );
  }

  DataColumn buildRowHeader(String label) {
    return DataColumn(
        label: DefaultText(
          label,
          style: TextStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.bold),
          align: TextAlign.end,
        ));
  }

  DataCell buildRow({required String value}) {
    return DataCell(DefaultText(
      value,
      style: TextStyles.bodyTextStyle,
      align: TextAlign.end,
    ));
  }
  Future<void> saveMatches() async {
    int? newWinNumber = int.tryParse(winNumberController.text.toString());
    if (newWinNumber != null && newWinNumber < 1000) {
      if (newWinNumber != _selectedMatch.winnerNumber) {
        DigitMatch tempMatch = _selectedMatch;
        tempMatch.winnerNumber = winNumberController.text.toString();

        showLoadingDialog(
            context: context,
            title: "Set $_selectedMatchId 's Win Number",
            content: "saving...");
        FirebaseFirestore.instance
            .collection(Collections.match)
            .doc(_selectedMatchId)
            .set(tempMatch.toJson())
            .then((value) {
          BlocProvider.of<MatchBloc>(context).add(GetAllMatch());
          Navigator.of(context).pop();
          Toasts.showSuccessToast("Save Successfully");
        }).catchError((error) {
          winNumberController.text = _selectedMatch.winnerNumber.toString();
          Navigator.of(context).pop();
          Toasts.showErrorMessageToast("Failed to change AM Match: $error");
        });
      } else {
        Toasts.showErrorMessageToast("Noting To Change");
      }
    } else {
      winNumberController.text = _selectedMatch.winnerNumber.toString();
    }
  }

  void getLoadData() {
    BlocProvider.of<WinNumberBloc>(context).add(GetWinNumberEvent(
        accounts: (_selectedType == "in")
            ? _selectedMatch.inAccounts
                .where((element) => element.type == "input")
                .toList()
            : _selectedMatch.outAccounts,
        type: _selectedType,
        matchId: _selectedMatch));
  }
}
