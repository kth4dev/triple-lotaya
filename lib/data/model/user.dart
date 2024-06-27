import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(explicitToJson: true)
class Account{
  String name;
  String password;
  int commission;
  int percent;
  String type;
  String? referUser;
  int createdDate;


  Account({required this.name,required  this.password, required this.commission,required  this.percent,required  this.type,required this.createdDate,required this.referUser});

  factory Account.fromJson(Map<String, dynamic?> json) => _$AccountFromJson(json);

  Map<String, dynamic?> toJson() => _$AccountToJson(this);


}