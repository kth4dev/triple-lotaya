part of 'win__number_bloc.dart';

@immutable
abstract class WinNumberState {}

class WinNumberInitial extends WinNumberState {}

class WinNumberLoadingState extends WinNumberState {}

class WinNumberLoadedState extends WinNumberState {
  final Map<String,int> winList;
  final int total;
  WinNumberLoadedState({required this.winList,required this.total});
}

class WinNumberErrorState extends WinNumberState {
  final String message;
  WinNumberErrorState({required this.message});
}

