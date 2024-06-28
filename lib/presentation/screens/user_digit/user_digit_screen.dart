import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lotaya/core/extensions/size_extension.dart';
import 'package:lotaya/core/values/constants.dart';
import 'package:lotaya/presentation/bloc/user_digits/user_digits_bloc.dart';

import '../../../core/styles/appbars/appbar.dart';
import '../../../core/styles/dropdowns/under_line_drop_down_button.dart';
import '../../../core/styles/textstyles/default_text.dart';
import '../../../core/styles/textstyles/textstyles.dart';
import '../../../data/model/match.dart';
import '../../bloc/matche/match_bloc.dart';
import '../../widgets/empty_match.dart';

class UserDigitScreen extends StatefulWidget {
  const UserDigitScreen({super.key});

  @override
  State<UserDigitScreen> createState() => _UserDigitScreenState();
}

class _UserDigitScreenState extends State<UserDigitScreen> {
  String _selectedMatchId = "";
  String _selectedType = "in";
  String _selectedUser = "All";
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
      appBar: defaultAppBar(context, title: "လယ်ဂျာ"),
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
                BlocProvider.of<UserDigitsBloc>(context).add(GetUserDigits(
                    digitMatch: _selectedMatch, type: _selectedType));
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
                    width: (MediaQuery.of(context).size.width >= 900)
                        ? 900
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
                                      BlocProvider.of<UserDigitsBloc>(context)
                                          .add(GetUserDigits(
                                              digitMatch: _selectedMatch,
                                              type: _selectedType));
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
                                      _selectedUser = "All";
                                      _selectedType = newValue;
                                      BlocProvider.of<UserDigitsBloc>(context)
                                          .add(GetUserDigits(
                                              digitMatch: _selectedMatch,
                                              type: _selectedType));
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        14.paddingHeight,
                        UnderLineDropDownButton(
                          initialValue: _selectedUser,
                          values: (_selectedType == "in")
                              ? ["All", ..._selectedMatch.inAccountUserName]
                              : ["All", ..._selectedMatch.outAccountUserName],
                          label: "User",
                          onChange: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedUser = newValue;
                              });
                            }
                          },
                        ),
                        5.paddingHeight,
                        Expanded(
                          child: BlocBuilder<UserDigitsBloc, UserDigitsState>(
                              builder: (context, state) {
                            if (state is UserDigitsLoadedState) {
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: DefaultText(
                                        "All Total = ${formatMoneyForNum(state.total)}",
                                        style: TextStyles.titleTextStyle),
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                        itemCount:
                                            state.userDigitsModelList.length,
                                        itemBuilder: (context, index) {
                                          int colorIndex = 0;
                                          int total = 0;
                                          for (var amount in state
                                              .userDigitsModelList[index]
                                              .digitAmount) {
                                            total += amount;
                                          }
                                          if (_selectedUser == "All" ||
                                              _selectedUser ==
                                                  state
                                                      .userDigitsModelList[
                                                          index]
                                                      .userName) {
                                            return Card(
                                              child: ExpansionTile(
                                                title: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    DefaultText(
                                                        state
                                                            .userDigitsModelList[
                                                                index]
                                                            .userName,
                                                        style: TextStyles
                                                            .bodyTextStyle),
                                                    DefaultText(
                                                        formatMoney(total),
                                                        style: TextStyles
                                                            .bodyTextStyle),
                                                  ],
                                                ),
                                                children: [
                                                  Container(
                                                    color:
                                                        const Color(0xffdcdcdc),
                                                    child: ListView.builder(
                                                      shrinkWrap: true,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      itemCount: state
                                                          .userDigitsModelList[
                                                              index]
                                                          .digitAmount
                                                          .length,
                                                      itemBuilder: (context,
                                                          digitAmountIndex) {
                                                        if (state
                                                                    .userDigitsModelList[
                                                                        index]
                                                                    .digitAmount[
                                                                digitAmountIndex] >
                                                            0) {
                                                          colorIndex += 1;
                                                          return Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        8.0,
                                                                    horizontal:
                                                                        14),
                                                            color: ((_selectedMatch.winnerNumber ??
                                                                            "")
                                                                        .isNotEmpty &&
                                                                    _selectedMatch
                                                                            .winnerNumber ==
                                                                        "${(digitAmountIndex < 10) ? 0 : ""}$digitAmountIndex")
                                                                ? Colors.green
                                                                : (colorIndex
                                                                        .isEven)
                                                                    ? Color(
                                                                        0xffF3F3F3)
                                                                    : Colors
                                                                        .white,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                DefaultText(
                                                                    "${(digitAmountIndex < 10) ? 0 : ""}$digitAmountIndex",
                                                                    style: TextStyles
                                                                        .titleTextStyle),
                                                                DefaultText(
                                                                    formatMoney(state
                                                                            .userDigitsModelList[
                                                                                index]
                                                                            .digitAmount[
                                                                        digitAmountIndex]),
                                                                    style: TextStyles
                                                                        .bodyTextStyle),
                                                              ],
                                                            ),
                                                          );
                                                        }

                                                        return SizedBox();
                                                      },
                                                    ),
                                                  ),
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            bottom: 1),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 14.0,
                                                        vertical: 8),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        const DefaultText(
                                                            "Total",
                                                            style: TextStyles
                                                                .titleTextStyle),
                                                        DefaultText(
                                                            formatMoney(total),
                                                            style: TextStyles
                                                                .bodyTextStyle),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            );
                                          }

                                          return SizedBox();
                                        }),
                                  ),
                                ],
                              );
                            }
                            return Container();
                          }),
                        )
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
}
