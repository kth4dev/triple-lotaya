import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lotaya/core/utils/digit_utils.dart';
import 'package:lotaya/data/model/match.dart';
import 'package:lotaya/data/model/user.dart';
import 'package:meta/meta.dart';

import '../../../data/collections.dart';
import '../../../domain/utils.dart';
import '../../screens/sales/slip.dart';

part 'list_event.dart';

part 'list_state.dart';

class ListBloc extends Bloc<ListEvent, ListState> {
  ListBloc() : super(ListInitial()) {
    on<GetListEvent>(getLists);
  }

  FutureOr<void> getLists(GetListEvent event, Emitter<ListState> emit) async {
    emit(ListLoadingState());
    List<ListModel> inList = [];

    for (Account e in event.match.inAccounts) {
      if (isAccountContain(e) && e.type == "input") {
        inList.add(ListModel(
            account: e,
            salePrices: 0,
            commission: 0,
            winAmount: 0,
            winGetAmount: 0,
            profit: 0,
            twitAmount: 0,
            twitGetAmount: 0));
      }
    }
    List<ListModel> outList = event.match.outAccounts
        .map((e) => ListModel(
            account: e,
            salePrices: 0,
            commission: 0,
            winAmount: 0,
            winGetAmount: 0,
            profit: 0,
            twitAmount: 0,
            twitGetAmount: 0))
        .toList();

    try {
      final documentSnapshot = await FirebaseFirestore.instance
          .collection(Collections.match)
          .doc(event.match.matchId)
          .collection("in")
          .get();
      documentSnapshot.docs.map((DocumentSnapshot document) {
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        Slip slip = Slip.fromJson(data);
        print(slip.totalAmount);

        ///find account
        for (int i = 0; i < inList.length; i++) {
          if (inList[i].account!.name == slip.userName) {
            inList[i].salePrices = inList[i].salePrices + slip.totalAmount;

            ///get win amount
            if (event.match.winnerNumber != null) {
              int winNumber = int.parse(event.match.winnerNumber!);
              for (var receipt in slip.receipts) {
                for (var digit in receipt.digitList) {
                  if (digit.value == event.match.winnerNumber.toString()) {
                    inList[i].winAmount = inList[i].winAmount + digit.amount;
                  }
                  if (digit.value == DigitUtils.getTwitBigger(winNumber) ||
                      digit.value == DigitUtils.getTwitSmaller(winNumber)) {
                    inList[i].twitAmount = inList[i].twitAmount + digit.amount;
                  }
                }
              }
            }
          }
        }
      }).toList();

      ///caculation
      for (int i = 0; i < inList.length; i++) {
        double netAmount = inList[i].salePrices -
            (inList[i].salePrices * (inList[i].account!.commission / 100));
        num totalGetWinAmount =
            inList[i].winAmount * inList[i].account!.percent;
        num totalGetTwitAmount = inList[i].twitAmount * 10;
        num profit =
            netAmount.toInt() - (totalGetTwitAmount + totalGetWinAmount);

        inList[i].profit = profit;
        inList[i].winGetAmount = totalGetWinAmount;
        inList[i].twitGetAmount = totalGetTwitAmount;
        inList[i].commission = netAmount;
      }

      final outDocuments = await FirebaseFirestore.instance
          .collection(Collections.match)
          .doc(event.match.matchId)
          .collection("out")
          .get();
      outDocuments.docs.map((DocumentSnapshot document) {
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        Slip slip = Slip.fromJson(data);
        print(slip.totalAmount);

        ///find account
        for (int i = 0; i < outList.length; i++) {
          if (outList[i].account!.name == slip.userName) {
            outList[i].salePrices = outList[i].salePrices + slip.totalAmount;

            ///get win amount
            if (event.match.winnerNumber != null) {
              int winNumber = int.parse(event.match.winnerNumber!);
              for (var receipt in slip.receipts) {
                for (var digit in receipt.digitList) {
                  if (digit.value == event.match.winnerNumber.toString()) {
                    outList[i].winAmount = outList[i].winAmount + digit.amount;
                  }
                  if (digit.value == DigitUtils.getTwitBigger(winNumber) ||
                      digit.value == DigitUtils.getTwitSmaller(winNumber)) {
                    outList[i].twitAmount =
                        outList[i].twitAmount + digit.amount;
                  }
                }
              }
            }
          }
        }
      }).toList();

      ///caculation
      for (int i = 0; i < outList.length; i++) {
        double netAmount =
            (outList[i].salePrices * (outList[i].account!.commission / 100));
        num totalGetWinAmount =
            outList[i].winAmount * outList[i].account!.percent;
        num totalGetTwitAmount = outList[i].twitAmount * 10;
        num profit =
            (netAmount.toInt() + totalGetWinAmount + totalGetTwitAmount) - outList[i].salePrices;

        outList[i].profit = profit;
        outList[i].winGetAmount = totalGetWinAmount;
        outList[i].twitGetAmount = totalGetTwitAmount;
        outList[i].commission = netAmount;
      }

      emit(ListLoadedState(inList: inList, outList: outList));
    } on Exception catch (onError) {
      emit(ListErrorState(errorMessage: "Failed to get list : $onError"));
    }
  }
}
