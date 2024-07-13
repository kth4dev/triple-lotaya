part of 'list_bloc.dart';

@immutable
abstract class ListState {}

class ListInitial extends ListState {}

class ListLoadingState extends ListState {}

class ListLoadedState extends ListState {
  final List<ListModel> inList, outList;

  ListLoadedState({required this.inList, required this.outList});
}

class ListErrorState extends ListState {
  final String errorMessage;

  ListErrorState({required this.errorMessage});
}

class ListModel {
  Account? account;
  num salePrices;
  num commission;
  num winAmount;
  num winGetAmount;
  num twitAmount;
  num twitGetAmount;
  num profit;

  ListModel(
      {this.account,
      required this.salePrices,
      required this.commission,
      required this.winAmount,
      required this.winGetAmount,
      required this.twitAmount,
      required this.twitGetAmount,
      required this.profit});
}
