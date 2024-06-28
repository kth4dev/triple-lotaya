import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lotaya/core/extensions/size_extension.dart';
import 'package:lotaya/core/styles/styles.dart';

import '../../../data/collections.dart';
import '../../../data/model/match.dart';
import '../../bloc/matche/match_bloc.dart';
import '../sales/slip.dart';

class PersonSaleListScreen extends StatefulWidget {
  const PersonSaleListScreen({Key? key}) : super(key: key);

  @override
  State<PersonSaleListScreen> createState() => _PersonSaleListScreenState();
}

class _PersonSaleListScreenState extends State<PersonSaleListScreen> {
  String _selectedMatchId = "";
  late DigitMatch _selectedMatch;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(context, title: "ရောင်းကြေး"),
      body: Padding(
        padding: (MediaQuery.of(context).size.width > 600) ? const EdgeInsets.all(10.0) : const EdgeInsets.all(5),
        child: BlocBuilder<MatchBloc, MatchState>(
          builder: (context, state) {
            if (state is MatchLoadingState) {
              return const Center(child: SizedBox(width: 50, height: 50, child: CircularProgressIndicator()));
            }
            if (state is MatchLoadedState) {
              List<String> matches = [];
              state.matchList.map((e) => matches.add("${e.date}")).toList();
              if (_selectedMatchId == "" && matches.isNotEmpty) {
                _selectedMatchId = matches[0];
                _selectedMatch = state.matchList[0];
              }

              print(_selectedMatch.hotNumbers?.toString());

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

                                for(int i=0;i<state.matchList.length;i++){
                                  if(state.matchList[i].isActive){
                                    _selectedMatchId = matches[i];
                                    _selectedMatch = state.matchList[i];
                                  }
                                }
                              });
                            }
                          },
                        ),
                      ),
                      10.paddingHeight,
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance.collection(Collections.match).doc(_selectedMatchId).collection("in").snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return DefaultText("No Internet Connection", style: TextStyles.bodyTextStyle.copyWith(color: Colors.orange));
                              }
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: SizedBox(width: 50, height: 50, child: CircularProgressIndicator()));
                              }

                              List<PersonSaleData> personSaleDataList = [];

                              snapshot.data!.docs.map((DocumentSnapshot document) {
                                Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                                Slip slip = Slip.fromJson(data);
                                if (!personSaleDataList.map((item) => item.userName).contains(slip.userName)) {
                                  personSaleDataList.add(PersonSaleData(userName: slip.userName, slips: [slip], totalAmount: slip.totalAmount));
                                } else {
                                  for (var i = 0; i < personSaleDataList.length; i++) {
                                    if (personSaleDataList[i].userName == slip.userName) {
                                      PersonSaleData updatedPersonSale = personSaleDataList[i];
                                      updatedPersonSale.totalAmount += slip.totalAmount;
                                      updatedPersonSale.slips.add(slip);
                                      personSaleDataList[i] = updatedPersonSale;
                                    }
                                  }
                                }
                              }).toList();

                              return Column(
                                children: [
                                  Card(
                                    color:Colors.blue,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                                      width: (MediaQuery.of(context).size.width > 500) ? 500 : double.infinity,
                                      child: Row(
                                        children: [
                                          Expanded(child: DefaultText("Name", style: TextStyles.titleTextStyle.copyWith(color: Colors.white))),
                                          7.paddingWidth,
                                          Expanded(child: DefaultText("All", style: TextStyles.titleTextStyle.copyWith(color: Colors.white))),
                                          7.paddingWidth,
                                          Expanded(child: DefaultText("Net", style: TextStyles.titleTextStyle.copyWith(color: Colors.white))),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                        itemCount: personSaleDataList.length,
                                        itemBuilder: (context, index) {
                                          int? commission;
                                          for (var user in _selectedMatch.inAccounts) {
                                            if (user.name == personSaleDataList[index].userName) {
                                              commission = user.commission;
                                            }
                                          }
                                          return Card(
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                                              width: (MediaQuery.of(context).size.width > 500) ? 500 : double.infinity,
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      child: DefaultText("${personSaleDataList[index].userName} ${(commission != null) ? "(${commission}%)" : ""}", style: TextStyles.bodyTextStyle)),
                                                  7.paddingWidth,
                                                  Expanded(child: DefaultText(personSaleDataList[index].totalAmount.toString(), style: TextStyles.bodyTextStyle)),
                                                  7.paddingWidth,
                                                  (commission != null)
                                                      ? Expanded(
                                                          child: DefaultText("${personSaleDataList[index].totalAmount - (personSaleDataList[index].totalAmount * (commission / 100))}",
                                                              style: TextStyles.bodyTextStyle))
                                                      : const Expanded(child: SizedBox())
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                  ),
                                ],
                              );
                            }),
                      ),
                    ],
                  ),
                ),
              );
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

  @override
  void initState() {
    super.initState();
    BlocProvider.of<MatchBloc>(context).add(GetAllMatch());
  }
}

class PersonSaleData {
  String userName;
  List<Slip> slips;
  int totalAmount;

  PersonSaleData({required this.userName, required this.slips, required this.totalAmount});
}
