import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

import '../../../data/model/user.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountBloc() : super(AccountInitial()) {
    on<GetAccountsEvent>(getAccounts);
  }

  FutureOr<void> getAccounts(GetAccountsEvent event,Emitter<AccountState> emit) async{
    emit(AccountLoadingState());
    try{
      final  documentSnapshot=await FirebaseFirestore.instance.collection('users').get();
      List<Account> inAccountList=[];
      List<Account> outAccountList=[];
      documentSnapshot.docs.map((DocumentSnapshot document) {
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        Account account = Account.fromJson(data);
        if(account.type=="output"){
          outAccountList.add(account);
        }else{
          inAccountList.add(account);
        }
      }).toList();
      emit(AccountLoadedState(inAccountList: inAccountList, outAccountList: outAccountList));
    }on Exception catch (onError) {
      emit(AccountErrorState("Failed to get account : $onError"));
    }



  }
}
