import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lotaya/core/extensions/size_extension.dart';
import 'package:lotaya/core/styles/appbars/appbar.dart';
import 'package:lotaya/core/styles/styles.dart';
import 'package:lotaya/data/model/match.dart';
import 'package:lotaya/presentation/bloc/matche/match_bloc.dart';
import 'package:lotaya/presentation/screens/digits/find_digit_widget.dart';
import 'package:lotaya/presentation/widgets/empty_match.dart';

import '../../../core/values/constants.dart';
import '../../../data/collections.dart';
import '../sales/digit.dart';
import '../sales/slip.dart';

class DigitsScreen extends StatefulWidget {
  const DigitsScreen({Key? key}) : super(key: key);

  @override
  State<DigitsScreen> createState() => _DigitsScreenState();
}

class _DigitsScreenState extends State<DigitsScreen> {
  String _selectedMatchId = "";
  late DigitMatch _selectedMatch;
  TextEditingController digitSearchController=TextEditingController();
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(context, title: "ထိုးဂဏန်းများ"),
      body: Padding(
        padding: (MediaQuery.of(context).size.width > 600) ? const EdgeInsets.all(10.0) : const EdgeInsets.all(5),
        child: BlocBuilder<MatchBloc, MatchState>(
          builder: (context, state) {
            if (state is MatchLoadingState) {
              return const Center(child: SizedBox(width: 50, height: 50, child: CircularProgressIndicator()));
            }
            if (state is MatchLoadedState) {
              List<String> matches = [];
              state.matchList.map((e) => matches.add("${e.date} ${e.time}")).toList();
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
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    10.paddingHeight,
                    Center(
                      child: SizedBox(
                        width: (MediaQuery.of(context).size.width >= 400) ? 400 : MediaQuery.of(context).size.width,
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
                    ),
                    Expanded(child: _buildDigits),
                  ],
                );
              } else {
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

  Widget get _buildDigits => StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(Collections.match).doc(_selectedMatchId).collection("out").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return DefaultText("No Internet Connection", style: TextStyles.bodyTextStyle.copyWith(color: Colors.orange));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: SizedBox(width: 50, height: 50, child: CircularProgressIndicator()));
        }

        List<int> outDigits = List.generate(100, (index) => 0);
        int outTotal = 0;
        snapshot.data!.docs.map((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          Slip s = Slip.fromJson(data);
          outTotal += s.totalAmount;
          for (var receipt in s.receipts) {
            for (var digit in receipt.digitList) {
              outDigits[int.parse(digit.value)] = outDigits[int.parse(digit.value)] + digit.amount;
            }
          }
        }).toList();

        return StreamBuilder(
            stream: FirebaseFirestore.instance.collection(Collections.match).doc(_selectedMatchId).collection("in").snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return DefaultText("No Internet Connection", style: TextStyles.bodyTextStyle.copyWith(color: Colors.orange));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: SizedBox(width: 50, height: 50, child: CircularProgressIndicator()));
              }

              List<int> inDigits = List.generate(100, (index) => 0);
              //win 
              List<Slip> inSlips=[];
              int inTotal = 0;
              snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                Slip s = Slip.fromJson(data);
                inSlips.add(s);
                inTotal += s.totalAmount;
                for (var receipt in s.receipts) {
                  for (var digit in receipt.digitList) {
                    inDigits[int.parse(digit.value)] = inDigits[int.parse(digit.value)] + digit.amount;
                  }
                }
                
                
              }).toList();

              List<Digit> overDigitList = []; // just use value and amount
         //     int totalOverAmount = 0;
              for (int i = 0; i < 100; i++) {
                int value = inDigits[i] - outDigits[i];
                if (value > _selectedMatch.breakAmount) {
               //   totalOverAmount += value - _selectedMatch.breakAmount;
                  overDigitList.add(Digit(amount: value - _selectedMatch.breakAmount, value: (i < 10) ? "0$i" : "$i", createdTime: 0, createUser: ""));
                }
              }
              
  
              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Wrap(
                      children: [
                        DefaultText("IN [ ${formatMoney(inTotal)} ]", style: TextStyles.subTitleTextStyle.copyWith(color: Colors.black)),
                        10.paddingWidth,
                        DefaultText("OUT [ ${formatMoney(outTotal)} ]", style: TextStyles.subTitleTextStyle.copyWith(color: Colors.black)),
                        10.paddingWidth,
                        DefaultText("Net [ ${formatMoney(inTotal - outTotal)} ]", style: TextStyles.subTitleTextStyle.copyWith(color: Colors.black)),
                        10.paddingWidth,
                        DefaultText("Break : ${formatMoney(_selectedMatch.breakAmount)}", style: TextStyles.subTitleTextStyle.copyWith(color: Colors.red)),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.all((MediaQuery.of(context).size.width < 1000) ? 5 : 20),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            color: Color(0xffdcdcdc),
                            child: Row(
                              children: List.generate(10, (startIndex) {
                                return SizedBox(
                                  width: 130,
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: 10,
                                      itemBuilder: (context, endIndex) {
                                        int index = int.parse("$startIndex$endIndex");
                                        return Card(
                                          margin: const EdgeInsets.all(3),
                                          color: getBackGroundColor(inDigits[index] - outDigits[index]),
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(minHeight: 44),
                                            child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                                child: /* (MediaQuery.of(context).size.width > 700)
                                              ?*/
                                                    Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Align(
                                                        alignment: Alignment.center,
                                                        child: DefaultText((index < 10) ? " 0$index" : " $index", style: TextStyle(fontSize: getDigitFontSize(context), fontWeight: FontWeight.bold))),
                                                    Expanded(
                                                        child: Container(
                                                            padding: const EdgeInsets.only(right: 5),
                                                            alignment: Alignment.centerRight,
                                                            child: DefaultText(formatMoney(inDigits[index] - outDigits[index]), style: TextStyle(fontSize: getAmountFontSize(context),fontWeight: FontWeight.w500)))),
                                                  ],
                                                )

                                                ),
                                          ),
                                        );
                                      }),
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                      FindDigitWidget(slips: inSlips,controller:digitSearchController,selectedMatch: _selectedMatch,)
                    ],
                  ),
                ],
              );
            });
      });

  double? getDigitFontSize(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 700) {
      return 22;
    } else if (width > 400) {
      return 20;
    } else {
      return 18;
    }
  }

  Color getBackGroundColor(int amount) {
    if (amount == _selectedMatch.breakAmount) {
      return Color(0xffffffff);
    } else if (amount > _selectedMatch.breakAmount) {
      return Colors.red;
    } else {
      return Color(0xfff2f2f2);
    }
  }

  double? getAmountFontSize(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 700) {
      return 17;
    } else if (width > 400) {
      return 15;
    } else {
      return 13;
    }
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<MatchBloc>(context).add(GetAllMatch());
  }
}
