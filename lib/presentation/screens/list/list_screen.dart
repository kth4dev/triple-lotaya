import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lotaya/core/extensions/size_extension.dart';
import 'package:lotaya/core/values/constants.dart';
import 'package:lotaya/data/cache/cache_helper.dart';
import 'package:lotaya/presentation/bloc/list/list_bloc.dart';
import 'package:lotaya/presentation/widgets/empty_match.dart';

import '../../../core/styles/appbars/appbar.dart';
import '../../../core/styles/dropdowns/under_line_drop_down_button.dart';
import '../../../core/styles/textstyles/default_text.dart';
import '../../../core/styles/textstyles/textstyles.dart';
import '../../../data/model/match.dart';
import '../../bloc/matche/match_bloc.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({Key? key}) : super(key: key);

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  String _selectedMatchId = "";
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
      appBar: defaultAppBar(context, title: "စာရင်း"),
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
                BlocProvider.of<ListBloc>(context).add(GetListEvent(match: _selectedMatch));
              }
              if (matches.isNotEmpty) {
                if (_selectedMatch.winnerNumber != null) {
                  winNumberController.text = _selectedMatch.winnerNumber.toString();
                } else {
                  winNumberController.text = "";
                }

                return Column(
                  children: [
                    UnderLineDropDownButton(
                      initialValue: _selectedMatchId,
                      values: matches,
                      label: "Match",
                      onChange: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedMatchId = newValue;
                            _selectedMatch = state.matchList[matches.indexOf(newValue)];
                            BlocProvider.of<ListBloc>(context).add(GetListEvent(match: _selectedMatch));
                          });
                        }
                      },
                    ),
                    5.paddingHeight,
                    if (_selectedMatch.winnerNumber == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 5.0),
                        child: DefaultText("ပေါက်သီး မရှိပါ", style: TextStyles.bodyTextStyle),
                      ),
                    if (_selectedMatch.winnerNumber != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: DefaultText("ပေါက်သီး = ${_selectedMatch.winnerNumber}", style: TextStyles.titleTextStyle.copyWith(color: Colors.green)),
                      ),
                    Expanded(
                      child: BlocBuilder<ListBloc, ListState>(
                        builder: (context, listState) {
                          if (listState is ListLoadedState) {
                            ListModel inTotal = getTotal(listState.inList);
                            ListModel outTotal = getTotal(listState.outList);
                            num totalProfit = inTotal.profit + outTotal.profit;

                            return SingleChildScrollView(
                              child: Column(
                                children: [
                                  if (CacheHelper.getAccountInfo().type == "admin")
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: DefaultText("Total Profit = ${formatMoneyForNum(totalProfit)}", style: TextStyles.titleTextStyle.copyWith(color: (totalProfit > 0) ? Colors.green : Colors.red)),
                                    ),
                                  if (MediaQuery.sizeOf(context).width > 1000)
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                            child: Center(
                                          child: Container(
                                            margin: const EdgeInsets.all(4),
                                            child: Card(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: _buildInTable(listState.inList, inTotal))),
                                          ),
                                        )),
                                        if (CacheHelper.getAccountInfo().type == "admin")
                                          Expanded(
                                              child: Container(
                                            margin: const EdgeInsets.all(4),
                                            child: Card(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: _buildOutTable(listState.outList, outTotal))),
                                          )),
                                      ],
                                    ),
                                  if (MediaQuery.sizeOf(context).width <= 1000) Card(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: _buildInTable(listState.inList, inTotal))),
                                  if (MediaQuery.sizeOf(context).width <= 1000 && CacheHelper.getAccountInfo().type == "admin")
                                    Card(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: _buildOutTable(listState.outList, outTotal))),
                                ],
                              ),
                            );
                          }

                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                    ),
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

  Widget _buildInTable(List<ListModel> inList, ListModel total) {
    var list = inList.map((ListModel data) {
      return DataRow(cells: [
        buildRow(value: data.account?.name ?? ""),
        buildRow(value: formatMoneyForNum(data.salePrices)),
        buildRow(value: formatMoneyForNum(data.commission)),
        buildRow(value: formatMoneyForNum(data.winAmount)),
        buildRow(value: formatMoneyForNum(data.winGetAmount)),
        buildRow(value: formatMoneyForNum(data.profit)),
      ]);
    }).toList();
    list.add(DataRow(color: MaterialStateColor.resolveWith((states) => Color(0xfff5f3f3)), cells: [
      buildRow(value: "Total"),
      buildRow(value: formatMoneyForNum(total.salePrices)),
      buildRow(value: formatMoneyForNum(total.commission)),
      buildRow(value: formatMoneyForNum(total.winAmount)),
      buildRow(value: formatMoneyForNum(total.winGetAmount)),
      buildRow(value: formatMoneyForNum(total.profit)),
    ]));
    return DataTable(
        headingRowColor: MaterialStateColor.resolveWith((states) => Color(0xfff5f3f3)),
        columns: [
          buildRowHeader("အမည်"),
          buildRowHeader("ရောင်းရငွေ"),
          buildRowHeader("ကော်နှုတ်"),
          buildRowHeader("ဒဲ့"),
          buildRowHeader("လျှော်ကြေး"),
          buildRowHeader("အမြတ်"),
        ],
        rows: list);
  }

  Widget _buildOutTable(List<ListModel> outList, ListModel total) {
    var list = outList.map((ListModel data) {
      return DataRow(cells: [
        buildRow(value: data.account?.name ?? ""),
        buildRow(value: formatMoneyForNum(data.salePrices)),
        buildRow(value: formatMoneyForNum(data.commission)),
        buildRow(value: formatMoneyForNum(data.winAmount)),
        buildRow(value: formatMoneyForNum(data.winGetAmount)),
        buildRow(value: formatMoneyForNum(data.profit)),
      ]);
    }).toList();
    list.add(DataRow(color: MaterialStateColor.resolveWith((states) => Color(0xfff5f3f3)), cells: [
      buildRow(value: "Total"),
      buildRow(value: formatMoneyForNum(total.salePrices)),
      buildRow(value: formatMoneyForNum(total.commission)),
      buildRow(value: formatMoneyForNum(total.winAmount)),
      buildRow(value: formatMoneyForNum(total.winGetAmount)),
      buildRow(value: formatMoneyForNum(total.profit)),
    ]));
    return DataTable(
        headingRowColor: MaterialStateColor.resolveWith((states) => Color(0xfff5f3f3)),
        columns: [
          buildRowHeader("အမည်"),
          buildRowHeader("တင်ငွေ"),
          buildRowHeader("ကော်"),
          buildRowHeader("ဒဲ့"),
          buildRowHeader("လျှော်ကြေး"),
          buildRowHeader("အမြတ်"),
        ],
        rows: list);
  }

  ListModel getTotal(List<ListModel> lists) {
    final result = ListModel(salePrices: 0, commission: 0, winAmount: 0, winGetAmount: 0, profit: 0);
    for (var list in lists) {
      result.salePrices += list.salePrices;
      result.commission += list.commission;
      result.winAmount += list.winAmount;
      result.winGetAmount += list.winGetAmount;
      result.profit += list.profit;
    }
    return result;
  }

  DataColumn buildRowHeader(String label) {
    return DataColumn(
        label: DefaultText(
      label,
      style: TextStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.bold),
    ));
  }

  DataCell buildRow({required String value}) {
    return DataCell(DefaultText(
      value,
      style: TextStyles.bodyTextStyle,
    ));
  }
}
