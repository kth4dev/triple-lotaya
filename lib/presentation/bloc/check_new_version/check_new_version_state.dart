part of 'check_new_version_bloc.dart';

@immutable
abstract class CheckNewVersionState {}

class CheckNewVersionInitial extends CheckNewVersionState {}

class UpdateNewVersionState extends CheckNewVersionState {}
