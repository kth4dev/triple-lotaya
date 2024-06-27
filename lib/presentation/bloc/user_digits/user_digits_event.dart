part of 'user_digits_bloc.dart';

@immutable
abstract class UserDigitsEvent {}

class GetUserDigits extends UserDigitsEvent {
  final DigitMatch digitMatch;
  final String type;
  GetUserDigits({required this.digitMatch,required this.type});
}
