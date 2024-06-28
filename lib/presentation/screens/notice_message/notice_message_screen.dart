import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lotaya/core/extensions/size_extension.dart';
import 'package:lotaya/core/styles/appbars/appbar.dart';
import 'package:lotaya/data/model/message.dart';
import 'package:lotaya/presentation/screens/notice_message/notice_list_screen.dart';

import '../../../core/styles/dropdowns/under_line_drop_down_button.dart';
import '../../../core/styles/textstyles/default_text.dart';
import '../../../core/styles/textstyles/textstyles.dart';
import '../../../data/collections.dart';
import '../../../data/model/match.dart';
import '../../bloc/matche/match_bloc.dart';
import '../../widgets/empty_match.dart';

class NoticeMessageScreen extends StatefulWidget {
  const NoticeMessageScreen({Key? key}) : super(key: key);

  @override
  State<NoticeMessageScreen> createState() => _NoticeMessageScreenState();
}

class _NoticeMessageScreenState extends State<NoticeMessageScreen> {
  String _selectedMatchId = "";
  late DigitMatch _selectedMatch;
  late TextEditingController winNumberController;
  bool isFirstTime=true;
  @override
  void initState() {
    super.initState();
    isFirstTime=true;
    winNumberController = TextEditingController();
    BlocProvider.of<MatchBloc>(context).add(GetAllMatch());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithIcons(context, title: "အသိပေးစာ",actions: [
        IconButton(onPressed: playNoti, icon: Icon(Icons.volume_down))
      ]),
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

                for (int i = 0; i < state.matchList.length; i++) {
                  if (state.matchList[i].isActive) {
                    _selectedMatchId = matches[i];
                    _selectedMatch = state.matchList[i];
                  }
                }
              }

              if (matches.isNotEmpty) {
                if (_selectedMatch.winnerNumber != null) {
                  winNumberController.text = _selectedMatch.winnerNumber.toString();
                } else {
                  winNumberController.text = "";
                }
                return Center(
                  child: SizedBox(
                    width: (MediaQuery.of(context).size.width >= 900) ? 900 : MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        UnderLineDropDownButton(
                          initialValue: _selectedMatchId,
                          values: matches,
                          label: "Match",
                          onChange: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                isFirstTime=true;
                                _selectedMatchId = newValue;
                                _selectedMatch = state.matchList[matches.indexOf(newValue)];
                              });
                            }
                          },
                        ),
                        5.paddingHeight,
                        Expanded(
                          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                              stream: FirebaseFirestore.instance
                                  .collection(Collections.match)
                                  .doc(_selectedMatch.matchId)
                                  .collection(Collections.message)
                                  .orderBy('createdTimed', descending: true)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return DefaultText("No Internet Connection", style: TextStyles.bodyTextStyle.copyWith(color: Colors.orange));
                                }
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator()),
                                    ),
                                  );
                                }

                                if (snapshot.hasData) {
                                  if(!isFirstTime){
                                    playNoti();
                                  }
                                  isFirstTime=false;

                                }

                                List<Message> messagesAll = [];
                                List<Message> messagesDelete = [];
                                List<Message> messagesOverTime = [];
                                List<Message> messagesOverTotalAmount = [];
                                List<Message> messagesOverDigit = [];
                                List<Message> messagesInsertHotNumber = [];

                                snapshot.data!.docs.map((DocumentSnapshot document) {
                                  Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                                  Message message = Message.fromJson(data);
                                  messagesAll.add(message);
                                  if (message.title.contains(overTimeDeleteMessage)) {
                                    messagesDelete.add(message);
                                  }else if (message.title.contains("OverTime")) {
                                    messagesOverTime.add(message);
                                  } else if (message.title.contains("Over Total")) {
                                    messagesOverTotalAmount.add(message);
                                  } else if (message.title.contains("Over -")) {
                                    messagesOverDigit.add(message);
                                  } else if (message.title.contains("Over -")) {
                                    messagesOverDigit.add(message);
                                  } else if (message.title.contains("Hot Number")) {
                                    messagesInsertHotNumber.add(message);
                                  }
                                }).toList();

                                return DefaultTabController(
                                  length: 5,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 35,
                                        child: TabBar(
                                          labelColor: Colors.white,
                                          unselectedLabelColor: Colors.black,
                                          indicatorSize: TabBarIndicatorSize.label,
                                          indicator: const BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(15),
                                                  topRight: Radius.circular(15)),
                                              color: Colors.blue),
                                          tabs: [
                                            Tab(
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Text("All [ ${messagesAll.length} ]"),
                                              ),
                                            ),
                                            Tab(
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Text("Delete [ ${messagesDelete.length} ]"),
                                              ),
                                            ),
                                            Tab(
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Text("Over Time [ ${messagesOverTime.length} ]"),
                                              ),
                                            ),
                                            Tab(
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Text("Hot Number [ ${messagesInsertHotNumber.length} ]"),
                                              ),
                                            ),
                                            Tab(
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Text("Over Total Amount [ ${messagesOverTotalAmount.length} ]"),
                                              ),
                                            ),
                                            Tab(
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Text("Over Digit Amount [ ${messagesOverDigit.length} ]"),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: TabBarView(
                                          children: [
                                            NoticeListWidget(messages: messagesAll),
                                            NoticeListWidget(messages: messagesDelete),
                                            NoticeListWidget(messages: messagesOverTime),
                                            NoticeListWidget(messages: messagesInsertHotNumber),
                                            NoticeListWidget(messages: messagesOverTotalAmount),
                                            NoticeListWidget(messages: messagesOverDigit),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
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
              return DefaultText(state.errorMessage, style: TextStyles.bodyTextStyle.copyWith(color: Colors.red));
            }
            return const DefaultText("Something went wrong", style: TextStyles.bodyTextStyle);
          },
        ),
      ),
    );
  }

  void playNoti() async{
    const localPath = "audio/noti.mp3";
    AudioPlayer audioPlayer = AudioPlayer();
    await audioPlayer.play(AssetSource(localPath));
  }
}
