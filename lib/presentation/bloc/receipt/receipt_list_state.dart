part of 'receipt_list_bloc.dart';

@immutable
abstract class ReceiptListState {}

class ReceiptListInitial extends ReceiptListState {}

class ChangedReceiptList extends ReceiptListState {}
