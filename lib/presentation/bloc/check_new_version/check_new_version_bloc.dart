import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lotaya/core/values/constants.dart';
import 'package:meta/meta.dart';

part 'check_new_version_event.dart';

part 'check_new_version_state.dart';

class CheckNewVersionBloc extends Bloc<CheckNewVersionEvent, CheckNewVersionState> {
  CheckNewVersionBloc() : super(CheckNewVersionInitial()) {
    on<CheckVersionCode>(checkVersionCode);
  }

  FutureOr<void> checkVersionCode(CheckVersionCode event, Emitter<CheckNewVersionState> emit) async {
    try {
      final document = await FirebaseFirestore.instance.collection("app_info").doc("version").get();
      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
      int? releaseVersionCode=data["version_code"];
      if(releaseVersionCode!=null && releaseVersionCode>currentVersionCode){
        emit(UpdateNewVersionState());
      }
    } catch (e) {}
  }
}
