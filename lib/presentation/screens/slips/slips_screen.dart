import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lotaya/core/extensions/size_extension.dart';
import 'package:lotaya/presentation/screens/slips/user_slip_widget.dart';

import '../../../core/styles/appbars/appbar.dart';
import '../../../core/styles/dropdowns/under_line_drop_down_button.dart';
import '../../../core/styles/textstyles/default_text.dart';
import '../../../core/styles/textstyles/textstyles.dart';
import '../../../data/model/match.dart';
import '../../../data/model/user.dart';
import '../../../domain/utils.dart';
import '../../bloc/matche/match_bloc.dart';
import '../../widgets/empty_match.dart';

class SlipsScreen extends StatefulWidget {
  const SlipsScreen({Key? key}) : super(key: key);

  @override
  State<SlipsScreen> createState() => _SlipsScreenState();
}

class _SlipsScreenState extends State<SlipsScreen> {
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
      appBar: defaultAppBar(context, title: "စလစ်"),
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
              state.matchList.map((e) => matches.add(e.date)).toList();
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
                } else {
                  winNumberController.text = "";
                }
                return Center(
                  child: SizedBox(
                    width: (MediaQuery.of(context).size.width >= 600)
                        ? 600
                        : MediaQuery.of(context).size.width,
                    child: Column(
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
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        5.paddingHeight,
                        listWidget((_selectedType == "in")
                            ? _selectedMatch.inAccounts
                                .where((element) => (element.type == "input"))
                                .toList()
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

  Widget listWidget(List<Account> accounts) {
    return Expanded(
        child: Card(
            child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: accounts.map((account) {
            if (isAccountContain(account)) {
              return UserSlipWidget(
                  matchId: _selectedMatch.matchId,
                  type: _selectedType,
                  accountName: account.name,
                  winNumber: _selectedMatch.winnerNumber ?? "");
            } else {
              return const SizedBox();
            }
          }).toList(),
        ),
      ),
    )));
  }

  Widget buildRowHeader(String label, Alignment alignment) {
    return Expanded(
      child: Container(
          alignment: alignment,
          color: Colors.blue,
          padding: const EdgeInsets.all(8),
          child: DefaultText(
            label,
            style: TextStyles.subTitleTextStyle
                .copyWith(fontWeight: FontWeight.bold, color: Colors.white),
          )),
    );
  }

  Widget buildRow(String label, Alignment alignment) {
    return Expanded(
      child: Container(
          alignment: alignment,
          padding: const EdgeInsets.all(8),
          child: DefaultText(
            label,
            style: TextStyles.subTitleTextStyle.copyWith(color: Colors.black),
          )),
    );
  }
}
