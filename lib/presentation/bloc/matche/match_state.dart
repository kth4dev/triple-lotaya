part of 'match_bloc.dart';

@immutable
abstract class MatchState {}

class MatchInitial extends MatchState {}

class MatchLoadingState extends MatchState {}

class MatchLoadedState extends MatchState {
  List<DigitMatch> matchList;
  MatchLoadedState({required this.matchList});
}

class MatchErrorState extends MatchState {
  String errorMessage;
  MatchErrorState(this.errorMessage);
}
