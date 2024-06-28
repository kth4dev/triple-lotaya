import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lotaya/core/extensions/size_extension.dart';
import 'package:lotaya/core/styles/appbars/appbar.dart';
import 'package:lotaya/presentation/screens/digit_permission/create_digit_permission_widget.dart';
import 'package:lotaya/presentation/screens/digit_permission/digit_permission_list_widget.dart';

import '../../../core/styles/dropdowns/under_line_drop_down_button.dart';
import '../../../core/styles/textstyles/default_text.dart';
import '../../../core/styles/textstyles/textstyles.dart';
import '../../../data/model/match.dart';
import '../../../data/model/user.dart';
import '../../bloc/matche/match_bloc.dart';
import '../../widgets/empty_match.dart';

class DigitPermissionScreen extends StatefulWidget {
  const DigitPermissionScreen({Key? key}) : super(key: key);

  @override
  State<DigitPermissionScreen> createState() => _DigitPermissionScreenState();
}

class _DigitPermissionScreenState extends State<DigitPermissionScreen> {
  String _selectedMatchId = "";
  late DigitMatch _selectedMatch;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: defaultAppBar(context, title: "ထိုးကြေးကန့်သတ်ချက်"),
        /* body: ,*/
        body: BlocBuilder<MatchBloc, MatchState>(
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

                for (int i = 0; i < state.matchList.length; i++) {
                  if (state.matchList[i].isActive) {
                    _selectedMatchId = matches[i];
                    _selectedMatch = state.matchList[i];
                  }
                }
              }
              if(matches.isNotEmpty){
                List<Account> accountList = _selectedMatch.inAccounts;
                accountList.addAll(_selectedMatch.outAccounts);
                return ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: setUpUI(context, accountList),
                    ),
                  ],
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
        ));
  }

  Widget setUpUI(BuildContext context, List<Account> accounts) {
    Widget createMatchWidget = CreateDigitPermission(accounts: accounts,selectedMatch: _selectedMatch,);
    Widget matchListWidget = DigitPermissionListWidget(
      selectedMatch: _selectedMatch,
    );
    double width = MediaQuery.of(context).size.width;
    if (width > 1000) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Expanded(flex: 2, child: createMatchWidget), 10.paddingWidth, Expanded(flex: 3, child: matchListWidget)],
      );
    } else {
      return Column(
        children: [
          ExpansionTile(initiallyExpanded: true, title: DefaultText("ကန့်သတ်ချက်အသစ်ဖန်တီးခြင်း", style: TextStyles.titleTextStyle.copyWith(fontWeight: FontWeight.bold)), children: [
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: createMatchWidget,
            )
          ]),
          10.paddingHeight,
          matchListWidget
        ],
      );
    }
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<MatchBloc>(context).add(GetAllMatch());
  }
}
