// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'digit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Digit _$DigitFromJson(Map<String, dynamic> json) => Digit(
      amount: json['amount'] as int,
      value: json['value'] as String,
      createdTime: json['createdTime'] as int,
      createUser: json['createUser'] as String,
    );

Map<String, dynamic> _$DigitToJson(Digit instance) => <String, dynamic>{
      'value': instance.value,
      'amount': instance.amount,
      'createdTime': instance.createdTime,
      'createUser': instance.createUser,
    };
