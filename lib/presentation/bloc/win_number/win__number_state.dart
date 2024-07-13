part of 'win__number_bloc.dart';

@immutable
abstract class WinNumberState {}

class WinNumberInitial extends WinNumberState {}

class WinNumberLoadingState extends WinNumberState {}

class WinNumberLoadedState extends WinNumberState {
  final Map<String, WinAmount> winList;
  final int winTotal;
  final int twitTotal;

  WinNumberLoadedState({
    required this.winList,
    required this.winTotal,
    required this.twitTotal,
  });
}

class WinNumberErrorState extends WinNumberState {
  final String message;

  WinNumberErrorState({required this.message});
}
