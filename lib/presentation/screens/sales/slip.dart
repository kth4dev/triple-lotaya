import 'package:lotaya/presentation/screens/sales/receipt.dart';
import 'package:json_annotation/json_annotation.dart';

part 'slip.g.dart';




@JsonSerializable(explicitToJson: true)
class Slip{
  String userName;
  int totalAmount;
  List<Receipt> receipts;
  int id;
  bool isSave;

  Slip({required this.totalAmount,required this.receipts,required this.userName,required this.id,required this.isSave});

  factory Slip.fromJson(Map<String, dynamic> json) => _$SlipFromJson(json);

  Map<String, dynamic> toJson() => _$SlipToJson(this);
}