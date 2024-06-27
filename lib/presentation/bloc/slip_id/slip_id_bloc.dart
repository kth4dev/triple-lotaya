import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'slip_id_event.dart';
part 'slip_id_state.dart';

class SlipIdBloc extends Bloc<SlipIdEvent, SlipIdState> {
  SlipIdBloc() : super(SlipIdInitial()) {
    on<RefreshSlipIdEvent>(refreshSlipId);
  }

  FutureOr<void> refreshSlipId(RefreshSlipIdEvent event,Emitter emit){
    emit(RefreshedSlipIdState());
  }
}
