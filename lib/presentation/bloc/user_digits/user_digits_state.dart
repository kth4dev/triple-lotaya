part of 'user_digits_bloc.dart';

@immutable
abstract class UserDigitsState {}

class UserDigitsInitial extends UserDigitsState {}

class UserDigitsLoadingState extends UserDigitsState {}

class UserDigitsLoadedState extends UserDigitsState {
  final List<UserDigitModel> userDigitsModelList;
  final int total;

  UserDigitsLoadedState({required this.userDigitsModelList, required this.total});
}

class UserDigitsErrorState extends UserDigitsState {}

class UserDigitModel {
  String userName;
  List<int> digitAmount;

  UserDigitModel({required this.userName, required this.digitAmount});
}
