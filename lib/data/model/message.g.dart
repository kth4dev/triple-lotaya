// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      title: json['title'] as String,
      content: json['content'] as String,
      matchId: json['matchId'] as String,
      slipId: json['slipId'] as String,
      slipUserId: json['slipUserId'] as String,
      updatedUserId: json['updatedUserId'] as String,
      createdTimed: json['createdTimed'] as int,
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
      'matchId': instance.matchId,
      'slipId': instance.slipId,
      'slipUserId': instance.slipUserId,
      'updatedUserId': instance.updatedUserId,
      'createdTimed': instance.createdTimed,
    };
