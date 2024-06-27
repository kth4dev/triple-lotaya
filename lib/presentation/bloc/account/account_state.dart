part of 'account_bloc.dart';

@immutable
abstract class AccountState {}

class AccountInitial extends AccountState {}

class AccountLoadingState extends AccountState {}

class AccountLoadedState extends AccountState {
  final List<Account> inAccountList,outAccountList;
  AccountLoadedState({required this.inAccountList,required this.outAccountList});
}

class AccountErrorState extends AccountState {
  final String accountMessage;
  AccountErrorState(this.accountMessage);
}
