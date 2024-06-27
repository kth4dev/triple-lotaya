// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Slip _$SlipFromJson(Map<String, dynamic> json) => Slip(
      totalAmount: json['totalAmount'] as int,
      receipts: (json['receipts'] as List<dynamic>)
          .map((e) => Receipt.fromJson(e as Map<String, dynamic>))
          .toList(),
      userName: json['userName'] as String,
      id: json['id'] as int,
      isSave: json['isSave'] as bool,
    );

Map<String, dynamic> _$SlipToJson(Slip instance) => <String, dynamic>{
      'userName': instance.userName,
      'totalAmount': instance.totalAmount,
      'receipts': instance.receipts.map((e) => e.toJson()).toList(),
      'id': instance.id,
      'isSave': instance.isSave,
    };
