import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lotaya/data/model/match.dart';
import 'package:lotaya/data/model/user.dart';
import 'package:meta/meta.dart';

import '../../../data/collections.dart';
import '../../screens/sales/slip.dart';

part 'user_digits_event.dart';

part 'user_digits_state.dart';

class UserDigitsBloc extends Bloc<UserDigitsEvent, UserDigitsState> {
  UserDigitsBloc() : super(UserDigitsInitial()) {
    on<GetUserDigits>(getUserDigits);
  }

  FutureOr<void> getUserDigits(GetUserDigits event, Emitter<UserDigitsState> emit) async {
    emit(UserDigitsLoadingState());
    List<UserDigitModel> userDigitsModelList =[];

    if(event.type == "in"){
      for(Account account in event.digitMatch.inAccounts){
        if(account.type.toLowerCase()=="input"){
          userDigitsModelList.add(UserDigitModel(userName: account.name, digitAmount: List.generate(100, (index) => 0)));
        }
      }
    }else{
      userDigitsModelList=event.digitMatch.outAccounts.map((e) =>UserDigitModel(userName: e.name, digitAmount: List.generate(100, (index) => 0))).toList();
    }

    int total = 0;
    QuerySnapshot<Map<String, dynamic>> slipQuery = await FirebaseFirestore.instance.collection(Collections.match).doc(event.digitMatch.matchId).collection(event.type).get();
    for (DocumentSnapshot document in slipQuery.docs) {
      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
      Slip s = Slip.fromJson(data);
      total+=s.totalAmount;
      int index = userDigitsModelList.indexWhere((element) => element.userName == s.userName);
      for (var receipt in s.receipts) {
        for (var digit in receipt.digitList) {
          userDigitsModelList[index].digitAmount[int.parse(digit.value)] += digit.amount;
        }
      }
    }
    emit(UserDigitsLoadedState(userDigitsModelList: userDigitsModelList, total: total));
  }
}
