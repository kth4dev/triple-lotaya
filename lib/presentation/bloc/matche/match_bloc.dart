import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lotaya/data/collections.dart';
import 'package:lotaya/data/model/match.dart';
import 'package:meta/meta.dart';

part 'match_event.dart';
part 'match_state.dart';

class MatchBloc extends Bloc<MatchEvent, MatchState> {
  MatchBloc() : super(MatchInitial()) {
    on<GetAllMatch>(getAllMatch);
  }

  FutureOr<void> getAllMatch(GetAllMatch event,Emitter<MatchState> emit) async{
    emit(MatchLoadingState());
    try{
      final  documentSnapshot=await FirebaseFirestore.instance.collection(Collections.match).get();
      List<DigitMatch> matchList=[];
      documentSnapshot.docs.map((DocumentSnapshot document) {
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        DigitMatch match = DigitMatch.fromJson(data);
        matchList.add(match);
      }).toList();

      emit(MatchLoadedState(matchList: matchList.reversed.toList()));
    }on Exception catch (onError) {
      emit(MatchErrorState("Failed to get matches : $onError"));
    }
  }
}
