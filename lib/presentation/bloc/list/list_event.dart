part of 'list_bloc.dart';

@immutable
abstract class ListEvent {}

class GetListEvent extends ListEvent {
  final DigitMatch match;
  GetListEvent({required this.match});
}
