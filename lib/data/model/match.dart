import 'package:json_annotation/json_annotation.dart';
import 'package:lotaya/data/model/digit_permission.dart';
import 'package:lotaya/data/model/user.dart';

part 'match.g.dart';

@JsonSerializable(explicitToJson: true)
class DigitMatch{
  String date;
  int closeTime;
  bool isActive;
  int breakAmount;
  List<int>? hotNumbers;
  List<Account> inAccounts;
  List<Account> outAccounts;
  List<DigitPermission> digitPermission;
  String? winnerNumber;
  int createdDate;


  DigitMatch({required this.date,required this.inAccounts,required this.outAccounts,required  this.closeTime,required  this.isActive,required this.createdDate,this.hotNumbers,this.winnerNumber,required this.breakAmount,required this.digitPermission});

  factory DigitMatch.fromJson(Map<String, dynamic> json) => _$DigitMatchFromJson(json);

  Map<String, dynamic> toJson() => _$DigitMatchToJson(this);

  String get matchId => date;

  List<String> get inAccountUserName {
    List<String> accountNames=[];
    for(var account in inAccounts){
      if(account.type=="input"){
        accountNames.add(account.name);
      }

    }
    return accountNames;
  }

  List<String> get outAccountUserName {
    List<String> accountNames=[];
    for(var account in outAccounts){
      accountNames.add(account.name);
    }
    return accountNames;
  }


}