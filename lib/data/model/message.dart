import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';
@JsonSerializable(explicitToJson: true)
class Message{
  String title;
  String content;
  String matchId;
  String slipId;
  String slipUserId;
  String updatedUserId;
  int createdTimed;

  Message({required this.title,required this.content,required this.matchId,required this.slipId,required this.slipUserId,required this.updatedUserId,required this.createdTimed});

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

const String addHotNumberMessage="Hot Number";
const String overTimeInsertMessage="OverTime[add]";
const String overTimeSaveMessage="OverTime[save]";
const String overTimeDeleteMessage="[delete]";