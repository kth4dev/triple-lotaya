import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'receipt_list_event.dart';
part 'receipt_list_state.dart';

class ReceiptListBloc extends Bloc<ReceiptListEvent, ReceiptListState> {
  ReceiptListBloc() : super(ReceiptListInitial()) {
    on<ChangeReceiptListEvent>(changedReceiptList);
  }

  FutureOr<void> changedReceiptList(ChangeReceiptListEvent event,Emitter emit){
    emit(ReceiptListInitial());
    emit(ChangedReceiptList());
  }
}
