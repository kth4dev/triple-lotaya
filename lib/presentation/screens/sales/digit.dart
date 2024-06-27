import 'package:json_annotation/json_annotation.dart';

part 'digit.g.dart';

@JsonSerializable(explicitToJson: true)
class Digit{
  String value;
  int amount;
  int createdTime;
  String createUser;

  Digit({required this.amount,required this.value,required this.createdTime,required this.createUser});


  factory Digit.fromJson(Map<String, dynamic> json) => _$DigitFromJson(json);

  Map<String, dynamic> toJson() => _$DigitToJson(this);

}