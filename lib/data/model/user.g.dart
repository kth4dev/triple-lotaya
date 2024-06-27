// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) => Account(
      name: json['name'] as String,
      password: json['password'] as String,
      commission: json['commission'] as int,
      percent: json['percent'] as int,
      type: json['type'] as String,
      createdDate: json['createdDate'] as int,
      referUser: json['referUser'] as String?,
    );

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'name': instance.name,
      'password': instance.password,
      'commission': instance.commission,
      'percent': instance.percent,
      'type': instance.type,
      'referUser': instance.referUser,
      'createdDate': instance.createdDate,
    };
