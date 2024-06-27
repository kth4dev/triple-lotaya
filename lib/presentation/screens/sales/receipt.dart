import 'package:lotaya/presentation/screens/sales/digit.dart';

import 'package:json_annotation/json_annotation.dart';

part 'receipt.g.dart';

@JsonSerializable(explicitToJson: true)
class Receipt{
  String type;
  List<Digit> digitList;
  int totalAmount;

  Receipt({required this.type,required this.digitList,required this.totalAmount});

  factory Receipt.fromJson(Map<String, dynamic> json) => _$ReceiptFromJson(json);

  Map<String, dynamic> toJson() => _$ReceiptToJson(this);
}