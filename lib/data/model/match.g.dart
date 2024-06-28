// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DigitMatch _$DigitMatchFromJson(Map<String, dynamic> json) => DigitMatch(
      date: json['date'] as String,
      inAccounts: (json['inAccounts'] as List<dynamic>)
          .map((e) => Account.fromJson(e as Map<String, dynamic>))
          .toList(),
      outAccounts: (json['outAccounts'] as List<dynamic>)
          .map((e) => Account.fromJson(e as Map<String, dynamic>))
          .toList(),
      closeTime: json['closeTime'] as int,
      isActive: json['isActive'] as bool,
      createdDate: json['createdDate'] as int,
      hotNumbers:
          (json['hotNumbers'] as List<dynamic>?)?.map((e) => e as String).toList(),
      winnerNumber: json['winnerNumber'] as String?,
      breakAmount: json['breakAmount'] as int,
      digitPermission: (json['digitPermission'] as List<dynamic>)
          .map((e) => DigitPermission.fromJson(e))
          .toList(),
    );

Map<String, dynamic> _$DigitMatchToJson(DigitMatch instance) =>
    <String, dynamic>{
      'date': instance.date,
      'closeTime': instance.closeTime,
      'isActive': instance.isActive,
      'breakAmount': instance.breakAmount,
      'hotNumbers': instance.hotNumbers,
      'inAccounts': instance.inAccounts.map((e) => e.toJson()).toList(),
      'outAccounts': instance.outAccounts.map((e) => e.toJson()).toList(),
      'digitPermission':
          instance.digitPermission.map((e) => e.toJson()).toList(),
      'winnerNumber': instance.winnerNumber,
      'createdDate': instance.createdDate,
    };
