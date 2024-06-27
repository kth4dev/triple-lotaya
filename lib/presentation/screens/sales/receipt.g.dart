// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Receipt _$ReceiptFromJson(Map<String, dynamic> json) => Receipt(
      type: json['type'] as String,
      digitList: (json['digitList'] as List<dynamic>)
          .map((e) => Digit.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalAmount: json['totalAmount'] as int,
    );

Map<String, dynamic> _$ReceiptToJson(Receipt instance) => <String, dynamic>{
      'type': instance.type,
      'digitList': instance.digitList.map((e) => e.toJson()).toList(),
      'totalAmount': instance.totalAmount,
    };
