import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lotaya/core/utils/digit_utils.dart';
import 'package:lotaya/data/collections.dart';
import 'package:lotaya/data/model/match.dart';
import 'package:lotaya/data/model/win_amount.dart';
import 'package:meta/meta.dart';

import '../../../data/model/user.dart';
import '../../screens/sales/slip.dart';

part 'win__number_event.dart';

part 'win__number_state.dart';

class WinNumberBloc extends Bloc<WinNumberEvent, WinNumberState> {
  WinNumberBloc() : super(WinNumberInitial()) {
    on<GetWinNumberEvent>(getWinNumbers);
  }

  FutureOr<void> getWinNumbers(
      GetWinNumberEvent event, Emitter<WinNumberState> emit) async {
    emit(WinNumberLoadingState());
    if (event.matchId.winnerNumber != null) {
      final winNumber = int.parse(event.matchId.winnerNumber.toString());
      Map<String, WinAmount> winList = {
        for (var player in event.accounts)
          player.name: WinAmount(win: 0, twit: 0)
      };

      int sumTotal = 0;
      int sumTwitTotal = 0;
      QuerySnapshot<Map<String, dynamic>> winNumbers = await FirebaseFirestore
          .instance
          .collection(Collections.match)
          .doc(event.matchId.matchId)
          .collection(event.type)
          .get();
      for (DocumentSnapshot document in winNumbers.docs) {
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        Slip s = Slip.fromJson(data);
        for (var receipt in s.receipts) {
          for (var digit in receipt.digitList) {
            if (digit.value == event.matchId.winnerNumber.toString()) {
              winList[s.userName]!.win =
                  winList[s.userName]!.win + digit.amount;
              sumTotal += digit.amount;
            }
            if(digit.value == DigitUtils.getTwitSmaller(winNumber) || digit.value == DigitUtils.getTwitBigger(winNumber)){
              winList[s.userName]!.twit = winList[s.userName]!.twit + digit.amount;
              sumTwitTotal += digit.amount;
            }
          }
        }
      }
      emit(WinNumberLoadedState(winList: winList, winTotal: sumTotal,twitTotal: sumTwitTotal));
    }
  }
}
