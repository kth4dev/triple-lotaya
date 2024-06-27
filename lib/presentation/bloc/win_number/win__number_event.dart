part of 'win__number_bloc.dart';

@immutable
abstract class WinNumberEvent {}

class GetWinNumberEvent extends WinNumberEvent {
  final DigitMatch matchId;
  final String type;
  final List<Account> accounts;
  GetWinNumberEvent({required this.accounts,required this.type,required this.matchId});
}
